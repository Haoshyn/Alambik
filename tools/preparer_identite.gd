extends SceneTree

func _initialize() -> void:
	var source := Image.load_from_file("res://docs/art/identite/icone_source.png")
	if source == null or source.is_empty():
		push_error("Source de l'icone introuvable")
		quit(1)
		return
	var dossier := "res://assets/visual/identite/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dossier))
	for format in [["icone.png",512],["icone_android.png",192],["icone_adaptative.png",432]]:
		var image := source.duplicate() as Image
		image.resize(int(format[1]),int(format[1]),Image.INTERPOLATE_LANCZOS)
		if image.save_png(dossier + str(format[0])) != OK:
			quit(1)
			return
	var fond := Image.create(432,432,false,Image.FORMAT_RGB8)
	fond.fill(Color("07304d"))
	fond.save_png(dossier + "fond_adaptatif.png")
	print("IDENTITE : icones 512, 192 et 432 generees")
	quit()
