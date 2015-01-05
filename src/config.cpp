#include "config.hpp"

void loadConfig(){
	try
	{
		config = YAML::LoadFile("config.yml");
		apikeys = config["api_keys"].as<std::map<std::string,std::string> >();
	}
	catch(YAML::BadFile &e)
	{
		YAML::Node node;
		node["server"] = "server.address.here";
		node["port"] = "6667";
		node["nick"] = "clearbot";
		node["username"] = "clearbot";
		node["realName"] = "C++ Lua Extensible Architecture Reactive Bot";
		node["password"] = "myPassword";
		node["owner"] = "owners nick";
		node["modes"] = "+B";
		node["api_keys"];
		node["api_keys"]["google"] = "1234";
		node["api_keys"]["wunderground"] = "0988765";
		std::string yml = YAML::Dump(node);
		std::ofstream confFile;
		confFile.open("config.yml");
		confFile << yml;
		confFile.close();
		config = YAML::LoadFile("config.yml");
	}
	}
	
std::string getAPIKey(std::string key)
{
	return apikeys[key];
}

std::string getConfig(std::string s){
	return config[s].as<std::string>();
}

char* getConfigC(std::string s)
{
	return cstrc(config[s].as<std::string>());
}