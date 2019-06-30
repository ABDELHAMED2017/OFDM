function [H_f] = channel_downlink(N_bs, N_ms, fc, Nc, Np, sigma_2_alpha, sigma, tau_max, fs, K)
%Inputs:
%   N_bs����վ������
%   N_ms���������û�
%   fc�� ���ز�Ƶ��
%   Nc�� ��
%   Np�� ÿһ����·����
%   sigma_2_alpha: average power of path, generally, sigma_2_alpha = 1;
%   sigma�� �Ƕ���չ
%   tau_max�� �����ʱ
%   fs�� ������
%   K�� ���ز�����
%Outputs:
%   H_f���ŵ����� ��Ƶ�� N_ms*N_bs*K

%% ���ò���
lambda = 3e8/fc;
d_ant = lambda/2;
Lp = Nc*Np;
angle = sigma*pi/180;
ang_min = 2*angle;
ang_max = pi-angle*2;

%% ���ɵ���ʸ��
n_MS = (0:(N_ms-1)).';	% transmitter for A_MS
n_BS = (0:(N_bs-1)).';	% receiver for A_BS
phi_BS = ang_min + (ang_max-ang_min)*rand(Nc,1); % ���ɴ������ϵĽǶ�
phi = phi_BS*ones(1,Np) + ones(Nc,1)*((rand(1,Np)-0.5)*2*angle); % ���ɴ���·���ĽǶ�
phi = reshape(phi.',[1, Lp]);

theta_MS = ang_min + (ang_max-ang_min)*rand(Nc,1);	
theta = theta_MS*ones(1,Np) +ones(Nc,1)* ((rand(1,Np)-0.5)*2*angle); % ���ɴ���·���ĽǶ�
theta = reshape(theta.', [1, Lp]);
miu_BS = 2*pi*d_ant/lambda*cos(phi);
miu_MS = 2*pi*d_ant/lambda*cos(theta);
A_BS = exp(1i*n_BS*miu_BS)/sqrt(N_bs);
A_MS = exp(1i*n_MS*miu_MS)/sqrt(N_ms);

%% ����ʱ�� �� ·������ ��
tau = tau_max*rand(1, Lp);
tau = sort(tau);
miu_tau = 2*pi*tau*fs/K;
alpha_temp = sqrt(sigma_2_alpha/2)*(randn(1,Lp) + 1i*randn(1, Lp));
alpha = sort(alpha_temp, 'descend');

%% ���ɿ�Ƶ���ŵ�
H_f = zeros(K, N_ms, N_bs);
for k = 1:K
    D_diag = sqrt(N_ms*N_bs/Lp)*diag(alpha.*exp(1i*(k-1)*miu_tau));
    H_f(k,:,:) = A_MS * D_diag * A_BS';
end
end