#include "plugins.hpp"


void callPluginFunction(std::string command, std::string message, std::string channel, std::string nick, std::string prefix) {
	if (commandList.count(command) == 0)
		return;
		
	char* cmd = cstrc(commandList[command].func);
	bool secured = commandList[command].secured;
	bool proceed = true;
	if (nick == getConfig("owner"))
		proceed = true;
	else if (secured && !getAdmin(nick, channel)){
		client.Send(channel, "Sorry, you have no permission to run that command");
		proceed = false;
	}
		
	if (proceed){
		try {
		luabind::call_function<void>(L, cmd, cstrc(message), cstrc(channel), cstrc(nick), cstrc(prefix));
		}
		catch (luabind::error &e) {
			luabind::object error_msg(luabind::from_stack(e.state(), -1));
			std::cout << error_msg << std::endl;
			std::cout << "Lua script error while running command " << command << std::endl;
		}
		}
}
void loadPlugins()
{
	L = luaL_newstate();
	sieveList.clear();
	commandList.clear();
	coreCommandList.clear();
	std::vector<std::string> files = glob("plugins/*.lua");
	luabind::open(L);
	luaL_openlibs(L);
	luabind::module(L) [luabind::def("registerCommand",&registerCommand)];
	luabind::module(L) [luabind::def("registerCommand",&registerCommand_default)];
	luabind::module(L) [luabind::def("registerSieve", &registerSieve)];
	luabind::module(L) [luabind::def("join",&join)];
    luabind::module(L) [luabind::def("send",&sendMessage)];
    luabind::module(L) [luabind::def("sendRaw",&sendRaw)];	
    luabind::module(L) [luabind::def("getAPIKey", &getAPIKey)];
	luabind::module(L) [luabind::def("getNick", &getNick)];
	registerCoreCommand("help", getHelp);
	registerCoreCommand("join", joinChannel);
	registerCoreCommand("forget", forgetChannel);
	registerCoreCommand("reload", reload, true);
	registerCoreCommand("admin", modifyAdmins, true);
	registerCoreCommand("quit", quitIRC, true);
	registerCoreCommand("do", doRawCommand, true);
	registerCoreCommand("register", registerNick, true);
	registerCoreCommand("identify", identifyNick, true);
	registerCoreCommand("vhost", requestVHost, true);
	for(std::vector<std::string>::iterator it = files.begin(); it != files.end(); it++)
	{
		std::cout << "Plugin " + *it + " loaded" << std::endl;	
		try {
			luaL_dofile(L,cstrc(*it));
			luabind::call_function<void>(L, "initPlugin");
		}
		catch (luabind::error &e) {
			luabind::object error_msg(luabind::from_stack(e.state(), -1));
			std::cout << error_msg << std::endl;
		}
		catch (std::exception &e) {
			std::cout << "Unknown exception. Perhaps a plugin is empty?" << std::endl;
			std::cout << e.what() << std::endl;
		}
	}
	loadConfig();
}