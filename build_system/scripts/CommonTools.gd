class_name CommonTools

static func loadCfgToDictionary(filepath):
	var ret = {}
	var config = ConfigFile.new()
	var err = config.load(filepath)
	if !err:
		for section in config.get_sections():
			ret[section] = {}
			for k in config.get_section_keys(section):
				ret[section][k] = config.get_value(section, k)
	return ret
	
	
