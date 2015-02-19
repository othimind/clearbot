#include "config.hpp"
#include "globals.hpp"
#include "utils.hpp"
#include "plugins.hpp"
#include "commands.hpp"
#include "boost/function.hpp" 
#include "boost/bind.hpp" 
using namespace soci;

YAML::Node config;
lua_State* L;
IRCClient client;
std::list<std::string> sieveList;
std::map<std::string, securedCommand> commandList;
std::map<std::string, securedCoreCommand> coreCommandList;
std::map<std::string, std::string> apikeys;


void delegateSieve(IRCMessage message, IRCClient* client){
	std::string command = message.parameters.at(1);
	if (command == ".reload")
		return;
	std::string channel = message.parameters.at(0);
	std::string nick = message.prefix.nick;
	std::string prefix = message.prefix.prefix;
	for (std::list<std::string>::const_iterator iterator = sieveList.begin(), end = sieveList.end(); iterator != end; ++iterator) {
		char* func = cstrc(*iterator);
		try {
			luabind::call_function<void>(L, func, cstrc(command), cstrc(channel), cstrc(nick), cstrc(prefix));
		}
		catch (luabind::error &e) {
			luabind::object error_msg(luabind::from_stack(e.state(), -1));
			std::cout << error_msg << std::endl;
			std::cout << "Lua script error" << std::endl; 
		}
	}
}


void delegateCommand(IRCMessage message, IRCClient* client){
	std::string command = message.parameters.at(1).erase(0,1);
	std::vector<std::string> words = splitString(command, " ");
	std::string input = lower(words.at(0)); 

	if (coreCommandList.count(input) == 0)
		callPluginFunction(input, command.erase(0,words.at(0).size() + 1), message.parameters.at(0), message.prefix.nick, message.prefix.prefix);
	else {
	//	bool secured = coreCommandList[input].secured;
		bool proceed = false;
		if (message.prefix.nick == getConfig("owner"))
			proceed = true;
		if (proceed) {
			boost::function<void(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*)> someFunc;
			someFunc = boost::bind(coreCommandList[input].func, _1, _2, _3, _4);
			someFunc(words, message.parameters.at(0), message.prefix, client);
		}
	}

}

void handleInput(IRCMessage message, IRCClient* client){
	if (message.parameters.at(1).at(0) == '.' || message.parameters.at(1).at(0) == '!')
		delegateCommand(message, client);
	delegateSieve(message, client);
}

int main(){

	client.Debug(true);
	client.HookIRCCommand("376", &endMOTD);
	client.HookIRCCommand("PRIVMSG", &handleInput);
	client.HookIRCCommand("INVITE", &followInvite);
	loadPlugins();
	client.InitSocket();
	client.Connect(getConfigC("server"), atoi(getConfigC("port")));
	client.Login(getConfigC("nick"), getConfigC("username"));
	while(client.Connected()){
		client.ReceiveData();
	}
}
