% ef_sbatch_driver() - subclass of ef_base_driver that implements a driver
%                      for the slurm scheduler
%
% Usage:
%   >>  driver = ef_sbatch_driver()
%    
% Outputs:
%   driver  - for use with a scheduler
%
% See also:
%   @ef_sbatch_driver/format_scheduler
%   @ef_sbatch_driver/read_jobs

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Brad Kennedy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program (LICENSE.txt file in the root directory); if not, 
% write to the Free Software Foundation, Inc., 59 Temple Place,
% Suite 330, Boston, MA  02111-1307  USA

function obj = ef_sbatch_driver()
   obj = class(struct(), 'ef_sbatch_driver', ef_base_driver());
