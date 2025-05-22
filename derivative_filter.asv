function [keep, removedIdx] = derivative_filter(time, roc, thr_acc, tolerance, cap)
%Derivative_FILTER Filters ADS‑B RoC data using a derivative-based consistency rule.
%   [keep, removedIdx] = Derivative_FILTER(time, roc, thr_acc, W,
%   tolerance, cap) removes spikes in vertical acceleration and up to 'cap'
%   subsequent points if their RoC remains within ±tolerance of the
%   flagged RoC. 
%
%   Inputs:
%     time      - datetime vector of sample times
%     roc       - numeric vector of rate of climb (ft/min)
%     thr_acc   - acceleration threshold (ft/min)/s
%     tolerance - allowable RoC deviation (ft/min) after spike
%     cap       - maximum number of following points to remove
%
%   Outputs:
%     keep       - logical vector of length N (true = keep sample)
%     removedIdx - indices of samples removed by the filter

% Number of samples
n = numel(roc);
if numel(time)~=n
    error('Time and RoC vectors must have same length');
end

% Compute vertical acceleration (ft/min)/s
dt_sec = seconds(diff(time));
acc    = [0; diff(roc) ./ dt_sec];

% Initialize error mask
isErr = false(n,1);


  for i = 1:n
      if isErr(i)
          continue;  % already flagged
      end
      if abs(acc(i)) > thr_acc
          % Found a spike: flag this index
          flaggedRoc = roc(i);
          isErr(i) = true;
          % Flag up to 'cap' following points if RoC remains within tolerance
          for j = i+1 : min(i+cap, n)
              if abs(roc(j) - flaggedRoc) <= tolerance
                  isErr(j) = true;
              else
                  break;
              end
          end
      end
  end


% Build outputs
keep       = ~isErr;
removedIdx = find(isErr);
end
