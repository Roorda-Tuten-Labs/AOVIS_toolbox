function pprint(number, sig_digit, text)
% pretty print - display numbers to a specified sig digit along with text
% describing the result. output is text displayed in the command window.
%
% USAGE
% pprint(number, sig_digit, text)

if nargin < 3
    text = '';
end
if nargin < 2
    sig_digit = 3;
end

% first format the string

if numel(number) == 1
    text_val = [text '\t' '%g'];
else
    text_val = [text '\t' '%g' '\n'];
end

if sig_digit == -1 % don't round in this case
    string = sprintf(text_val, number);
else
    string = sprintf(text_val, round(number, sig_digit));
end

% now print
disp(string);

end