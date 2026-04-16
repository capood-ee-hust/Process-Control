%% 1. Định nghĩa Observation và Action
obsInfo = rlNumericSpec([3 1]);
obsInfo.Name = 'observations';
obsInfo.Description = 'integrated error, error, and measured temp';
numObservations = obsInfo.Dimension(1);

actInfo = rlNumericSpec([1 1]);
actInfo.Name = 'F3';
numActions = numel(actInfo);

%% 2. Tạo môi trường RL từ mô hình Simulink
env = rlSimulinkEnv('rlwatertank', 'rlwatertank/RL Agent', obsInfo, actInfo);
env.ResetFcn = @(in) localResetFcn(in);  % Hàm reset

Ts = 1.0;   % Sample time
Tf = 200;   % Tổng thời gian mô phỏng mỗi episode
rng(0);     % Đặt seed để kết quả lặp lại

%% 3. Tạo Critic Network
statePath = [
    imageInputLayer([numObservations 1 1], 'Normalization', 'none', 'Name', 'State')
    fullyConnectedLayer(50, 'Name', 'CriticStateFC1')
    reluLayer('Name', 'CriticRelu1')
    fullyConnectedLayer(25, 'Name', 'CriticStateFC2')];

actionPath = [
    imageInputLayer([numActions 1 1], 'Normalization', 'none', 'Name', 'Action')
    fullyConnectedLayer(25, 'Name', 'CriticActionFC1')];

commonPath = [
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'CriticCommonRelu')
    fullyConnectedLayer(1, 'Name', 'CriticOutput')];

criticNet = layerGraph();
criticNet = addLayers(criticNet, statePath);
criticNet = addLayers(criticNet, actionPath);
criticNet = addLayers(criticNet, commonPath);

criticNet = connectLayers(criticNet, 'CriticStateFC2', 'add/in1');
criticNet = connectLayers(criticNet, 'CriticActionFC1', 'add/in2');

criticOpts = rlRepresentationOptions('LearnRate', 1e-3, 'GradientThreshold', 1);
critic = rlQValueRepresentation(criticNet, obsInfo, actInfo, ...
    'Observation', {'State'}, 'Action', {'Action'}, criticOpts);

%% 4. Tạo Actor Network
actorNet = [
    imageInputLayer([numObservations 1 1], 'Normalization', 'none', 'Name', 'State')
    fullyConnectedLayer(3, 'Name', 'actorFC')
    tanhLayer('Name', 'actorTanh')
    fullyConnectedLayer(numActions, 'Name', 'Action')];

actorOpts = rlRepresentationOptions('LearnRate', 1e-4, 'GradientThreshold', 1);
actor = rlDeterministicActorRepresentation(actorNet, obsInfo, actInfo, ...
    'Observation', {'State'}, 'Action', {'Action'}, actorOpts);

%% 5. Cấu hình DDPG Agent
agentOpts = rlDDPGAgentOptions(...
    'SampleTime', Ts, ...
    'TargetSmoothFactor', 1e-3, ...
    'DiscountFactor', 0.99, ...
    'MiniBatchSize', 64, ...
    'ExperienceBufferLength', 1e7);

agentOpts.NoiseOptions.Variance = 0.3;
agentOpts.NoiseOptions.VarianceDecayRate = 1e-5;

agentDDPG = rlDDPGAgent(actor, critic, agentOpts);  % KHÔNG dùng tên agent để tránh lỗi

%% 6. Thiết lập tùy chọn huấn luyện
maxEpisodes = 5000;
maxSteps = ceil(Tf / Ts);

trainOpts = rlTrainingOptions(...
    'MaxEpisodes', maxEpisodes, ...
    'MaxStepsPerEpisode', maxSteps, ...
    'ScoreAveragingWindowLength', 20, ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', 1600);

%% 7. Huấn luyện agent
trainingStats = train(agentDDPG, env, trainOpts);

%% 8. Hàm reset: Random T0 từ 290 đến 350
function in = localResetFcn(in)
    % Nhiệt độ ban đầu T0 ∈ [300, 320]
    T0 = 300 + (320 - 300) * rand;

    % Cập nhật block nhiệt độ ban đầu - sửa đúng path block trong Simulink
    blk = 'rlwatertank/Water-Tank System/Integrator1';  % Thay đổi tùy mô hình
    in = setBlockParameter(in, blk, 'InitialCondition', num2str(T0));
end