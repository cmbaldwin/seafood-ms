class Category < ApplicationRecord
	has_ancestry
	has_many :articles

  def name_with_depth
	if depth > 0 
		link = "\\"
	else
		link = ""
	end
  	tree_link = link + ("__" * depth)

	"#{tree_link} #{name}"
  end

end
