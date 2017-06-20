fig/catfood-tree.png: fig/catfood-tree.dot
	dot -Tpng < "$<" > "$@"
