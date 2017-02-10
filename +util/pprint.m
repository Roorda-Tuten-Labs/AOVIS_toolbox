function pprint(number, sig_digit, text)

if nargin < 3
    text = '';
end
if nargin < 2
    sig_digit = 3;
end

% first format the string

if sig_digit == -1 % don't round in this case
    string = sprintf([text '\t' '%g'], number);
else
    string = sprintf([text '\t' '%g'], round(number, sig_digit));
end

% now print
disp(string);

end