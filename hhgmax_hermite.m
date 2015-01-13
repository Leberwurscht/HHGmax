% Calculates the physical hermite polynomials using the
% recurrrence relation H_{n+1}(x)= 2x H_n(x) - 2n H_{n-1}(x).
function H = hhgmax_hermite(n, x)

H_before = 0;
H = ones(size(x));

for ii=1:n
	H_current = 2*x .* H - 2*(ii-1) * H_before;

	H_before = H;
	H = H_current;
end

% normalize polynomial
H = H / sqrt(2^n * factorial(n));
