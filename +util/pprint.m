function pprint(number, sig_digit, text)

if nargin < 3
    text = '';
end
if nargin < 2
    sig_digit = 3;
end

string = sprintf([text '\t' '%g'], round(number, sig_digit));
disp(string);

end