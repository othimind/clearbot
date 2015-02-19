#pragma once
#include "soci/soci.h"
#include "soci/sqlite3/soci-sqlite3.h"
#include "globals.hpp"
#include "config.hpp"
#include "time.h"
#include "../includes/IRCClient.h"
#include "plugins.hpp"
void joinChannel(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void forgetChannel(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void getHelp(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void modifyAdmins(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void sendMessage(std::string, std::string );
void join(std::string);
void sendRaw(std::string);
bool getAdmin(std::string, std::string);
void registerCommand(std::string, std::string, bool secured=false);
void registerCoreCommand(std::string, void (*)(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*), bool secured=false);
void registerCommand_default(std::string, std::string);
void registerSieve(std::string );
void getHelp(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void followInvite(IRCMessage, IRCClient*);
void endMOTD(IRCMessage, IRCClient*);
void quitIRC(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void reload(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void doRawCommand(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void registerNick(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void identifyNick(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
void requestVHost(std::vector<std::string>, std::string, IRCCommandPrefix, IRCClient*);
std::string getNick();
