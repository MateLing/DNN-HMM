function [ stackedAEOptTheta ] = supervisedfinetuning( stackedAEOptTheta,train_x, train_y,hiddenSizeL2, numClasses, netconfig,lambda, opts, flag )
%FINETUNING Summary of this function goes here
%   Detailed explanation goes here

if ~exist('opts', 'var')
    opts = struct;
end

if ~isfield(opts, 'batchsize')   
    opts.batchsize = 100;
end

%%����mini-batch��ĵ�������epoch��ȡ1�͹����ˣ�Խ��Խ��ҲԽ��ȷ��
%����epoch=1�Ļ�����ʱ1s���ң���ȷ��91%;epoch=10,��ʱ10s���ң�׼ȷ��92.5%
if ~isfield(opts, 'numepochs')  
    opts.numepochs = 1;
end

if nargin<9
    flag=0;   %% flag to use minFunc. 1 to use, 0 otherwise
end

% Use minFunc to minimize the function
%addpath minFunc/
minFuncopts.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % softmaxCost.m satisfies this.
minFuncopts.display = 'off';
%%����mini-batch�ڵĵ�����������һ��epoch��batch��ʹ���ݶ��Ż��㷨�ĵ�����������Ϊʹ��mini-batch��
%��������1~3�ε����Ϳ��ԣ��������mini-batch����full batch��Ҫ����100��������,
%��ֵ��ǣ����ֵ���1��Ч���������죬����Խ��Խ���������⣬����Խ��Ч��Խ�����Ϊ���õ�����ֻ��һ��mini-batch
%��˵���Խ����������������batch�ľֲ����Ž⣬������mini-batch�Ĳ������ݶ��½�������һ�����Ҳ���
%��Ϊֻ����һ�Σ�����Ҳ��ȫ�����Լ�д�ݶ��½���
minFuncopts.maxIter = 1;

m = size(train_x, 1);
numbatches = m/opts.batchsize;

for i = 1 : opts.numepochs
    kk = randperm(m);
    Optcost = 0;
    for l = 1 : numbatches
        batch_x = train_x(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
        batch_y = train_y(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
        if flag
            [stackedAEOptTheta, cost] =  minFunc(@(p)supervisedstackedAECost(p,hiddenSizeL2,...
                             numClasses, netconfig,lambda, batch_x', batch_y),...
                            stackedAEOptTheta,minFuncopts);
            
        else
            [cost,grad]=supervisedstackedAECost(stackedAEOptTheta,hiddenSizeL2,numClasses, netconfig,lambda, batch_x', batch_y);
            stackedAEOptTheta = stackedAEOptTheta - opts.alpha * grad;
        end
            Optcost=Optcost+cost;
    end
    Optcost=Optcost/numbatches;
    fprintf(1,'epoch %d / %d. The value of fine tuning cost function: %6.3f\n',i,opts.numepochs,Optcost); 
end

end
