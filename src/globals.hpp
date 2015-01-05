#pragma once
#include <lua.hpp>
#include <luabind/luabind.hpp>
#include "yaml-cpp/yaml.h"
#include "../includes/IRCClient.h"
#include <string>
#include <vector>
extern YAML::Node config;
extern lua_State* L;
extern IRCClient client;
extern std::map<std::string, std::string> apikeys;
extern std::list<std::string> sieveList;
struct securedCommand {
		std::string func;
		bool secured;
};
struct securedCoreCommand {
		void (*func)(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
		bool secured;
};
extern std::map<std::string, securedCommand> commandList;
extern std::map<std::string, securedCoreCommand> coreCommandList;