function [lambda, Modes] = DMD_Duke(Snapshots, dt, Nmd, varargin)
%DMD_DUKE Compute Koopman modes by Dynamic Mode Decomposition algorithm by Duke et al.
%
% This is the algorithm by Duke, Daniel, Julio Soria, and Damon
% Honnery. 2012. “An Error Analysis of the Dynamic Mode Decomposition.”
% Experiments in Fluids 52 (2): 529–42. doi:10.1007/s00348-011-1235-7.
%
% [lambda, Modes] = DMD_Duke( Snapshots, dt, Nmd )
%    Compute DMD of data in Snapshots matrix. Columns of Snapshots are
%    measurements taken dt apart. Nmd is the number of modes to be
%    computed.
%
%    lambda -- list of complex Dynamic Mode frequencies, real part is the
%    decay rate, imaginary part (angular) frequency.
%    Modes  -- each column of the matrix is a Dynamic Mode, corresponding
%    to the lambda at the same index.
%
%    lambda and Modes are sorted by l2-norm of columns of Modes, in
%    descending order.
%
% [lambda, Modes] = DMD_Duke( ..., db ) If db set to true, first
%    "de-bias" using Hemati, Rowley procedure. Alternatively, if db is a
%    positive integer, use db modes to debias.
%

% Copyright information in LICENSE file of the package.

  % We assume that OutputSnapshots = KoopmanOperator( InputSnapshots )
  % column-by-column
  [InputSnapshots,OutputSnapshots] = debias(Snapshots, varargin{:});

  [Q,R] = qr(InputSnapshots);

  S = pinv(R) * Q' * OutputSnapshots;

  [X, lambda] = eigs(S, [], Nmd,'LR');
  lambda = diag(lambda);

  %% Calculate modes
  Modes = InputSnapshots * X;
  lambda = log(lambda);
  if nargin >= 2 && ~isempty(dt)
    lambda = lambda/dt;
  end

  [lambda, Modes] = sortmodes( lambda, Modes );