function CenterOfMass = center_of_mass(image)

C=cellfun(@(n) 1:n, num2cell(size(image)),'uniformoutput',0);
[C{:}]=ndgrid(C{:});
C=cellfun(@(x) x(:), C,'uniformoutput',0);
C=[C{:}];

CenterOfMass=image(:).'*C/sum(image(:),'double');

end