clc,clear
SNRdb = (0:5:30);
N_bs = 32;
N_ms = 1;
BW = 30.72e6;          %ϵͳ���� = 30.72MHz
fs = BW;
fc = 30e9;          % ���ز�Ƶ�� is 30GHz
lambda = 3e8/fc;
d_ant = lambda/2;
sigma_2_alpha = 1;  % variance of path gain
sigma = 7.5;
tau_max = 0.2e-6;   % ����ʱ����չ 200ns 0.2��s
Nc = 1;             %��
Np = 6;             %ÿ�����е�·������
Lp = Nc*Np;
cr = 0.5;      %ѹ����M/N
G = N_bs*cr;   %�൱��M��cr��M��N�ı�ֵ
A_R = dftmtx(N_bs)./sqrt(N_bs);
iter = 1000;
snr_len = length(SNRdb);
NMSE3 = zeros(snr_len,1);
% N=N_bs, M=G,ϡ���δ֪��K�ĺ��岻���
%% 1���ز�
nmse3 = zeros(iter,1);
fft_len = 1;
K = fft_len;  %���ز�����  

for jj = 1:snr_len
    for j =1 : iter
        [H_f] = channel_downlink(N_bs, N_ms, fc, Nc, Np, sigma_2_alpha,sigma,tau_max,fs,K);

        H_amp = permute(H_f, [3 2 1]);   %�൱��x
        S = (randn(G,N_bs,K) + 1i.*randn(G,N_bs,K))./sqrt(2);
        Y = zeros(G,K);
        H_ang_f = zeros(N_ms,N_bs,K);
        Phi = zeros(G,N_bs,K);
        for k = 1:K
            Y(:,k) = awgn(S(:,:,k)*H_amp(:,:,k),SNRdb(jj),'measured');
            H_ang_f(:,:,k) = A_R*H_amp(:,:,k); %�൱��theta,��x�ڸ���Ҷ����ϵ�����Ǵ��ָ����ŵ���
            Phi(:,:,k) = S(:,:,k)*A_R';        %Phi�൱�ڴ��о���A
        end
        
        %OMP
        sigma = std(Y)*10^(-SNRdb(jj)/20);
        sigma2 = sigma^2;
        H_omp_hat = OMP_delta(Phi, Y, sigma, 1);   %���Ƶ���theta,������ΪA��y���õ�theta
        nmse3(j,1) = (norm(H_omp_hat(:)-H_ang_f(:))^2/norm(H_ang_f(:))^2);
       
        
        disp(['Finished','  ',num2str(j),'/',num2str(iter)])
    end

    NMSE3(jj,1) = sum(nmse3)/iter;
end

%% plot
figure(1)
snr = (0:5:30);
plot(snr, 10*log10(NMSE3(:,1)), 'r-o');grid on;hold on;
% semilogy(snr, NMSE, 'b-*');grid on;
xlabel('SNR'),ylabel('NMSE');
legend('OMP')
title('1/2ѹ�� ');