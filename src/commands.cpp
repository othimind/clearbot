#include "commands.hpp"

using namespace soci;

void reload(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	loadPlugins();
}

void quitIRC(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	client->SendIRC("QUIT");
	client->Disconnect();
}

void doRawCommand(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	std::string command = boost::algorithm::join(words, " ");
	command = command.erase(0,words.at(0).size());
	sendRaw(command);
}

void registerNick(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	client->SendIRC("REGISTER " + getConfig("password") + " " + words.at(1));
}

void identifyNick(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	client->SendIRC("PRIVMSG nickserv identify " + getConfig("password"));
}

void requestVHost(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	client->Send("hostserv", "REQUEST " + words.at(1));
}

void joinChannel(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client){
	time_t rawtime;
	struct tm *currentTime;
	time ( &rawtime);
	currentTime = localtime(&rawtime);
	char buffer [80];
	strftime(buffer,80,"%F %T",currentTime);
	std::string timeString(buffer);
	std::string extra = "";
	bool nosave = false;
	if (words.size() == 3)
	{
		if (words.at(2) == "nosave")
			nosave = true;
		else
			nosave = false;
	}
	if (nosave == false)
	{
		session sql(sqlite3, "data/cbdata.db");
		sql << "create table if not exists autojoins(channel, user, added datetime, primary key (channel))";
		statement st = (sql.prepare << "insert into autojoins(channel,user,added) values(:channel,:user,:added)",use(words.at(1)),use(user.prefix),use(timeString));
		st.execute(true);
		nosave = " [this was not saved]";
	}
	client->Join(words.at(1));
	
	client->Send(user.nick,"Joining channel " + words.at(1) + extra);
}

void forgetChannel(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client)
{
	session sql(sqlite3, "data/cbdata.db");
	std::string creator;
	sql << "create table if not exists autojoins(channel, user, added datetime, primary key (channel))";
	sql << "select user from autojoins where channel = :chan",use(words.at(1)),into(creator);
	std::cout << creator << std::endl;
	std::cout << user.prefix << std::endl;
	if (creator == "")
	{
		client->Send(user.nick,"Channel is not listed as autojoin");
		return;
	}
	if (creator  == user.prefix || user.nick == getConfig("owner"))
	{
		statement st = (sql.prepare << "delete from autojoins where channel = :chan",use(words.at(1)));
		st.execute(true);
		client->Send(user.nick,"Forgetting channel " + words.at(1));
	}
	else
		client->Send(user.nick,"Sorry, you are not authorised to remove " + words.at(1));
}

void modifyAdmins(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	session sql(sqlite3, "data/cbdata.db");
	std::string isAdmin;
	indicator ind;
	std::string help = " .admins <add|remove|list> <channel> <user> -- modifies Admin userlist ";
	sql << "create table if not exists admins (channel, user, primary key (channel, user))";
	if (words.size() == 4) {
		if (words.at(1) == "add") {
		sql << "select user from admins where channel = :chan and user = :username",use(words.at(2)),use(words.at(3)),into(isAdmin, ind);
		if (sql.got_data()){
			switch(ind) {
				case i_ok:
					client->Send(user.nick, words.at(3) + " is already an admin for " + words.at(2));
					return;
					break;
			}
		}
		
		else	{
			statement st = (sql.prepare << "insert into admins(channel,user) values(:channel,:user)",use(words.at(2)),use(words.at(3)));
			st.execute(true);
			client->Send(user.nick, "User " + words.at(3) + " added as admin");
		}
		}
		else if (words.at(1) == "remove") {
			statement st = (sql.prepare << "delete from admins where channel = :chan and user = :user",use(words.at(2)),use(words.at(3)));
			st.execute(true);
			client->Send(user.nick, "User " + words.at(3) + " removed as admin");
		}
		else
			client->Send(user.nick, help);
	}
	else if (words.size() >= 2)
		if (words.at(1) == "list") {
			std::string users;
			rowset<row> rs = (sql.prepare << "select * from admins");
			for (rowset<row>::const_iterator it = rs.begin(); it != rs.end(); it++){
				row const& row = *it;
				users.append(row.get<std::string>(1) + " -- " + row.get<std::string>(0) );
				users.append(", ");
			}
			users = users.erase(users.size() - 2,users.size());
			client->Send(user.nick, "Admins are: " + users);
		}
		else
			client->Send(user.nick, help);
	else
		client->Send(user.nick, help);
}

void sendMessage(std::string channel, std::string message)
{       
        client.Send(channel, message);
}

void join(std::string channel)
{       
        client.Join(channel);
}

void sendRaw(std::string raw)
{
        client.SendIRC(raw);
}

bool getAdmin(std::string nick, std::string channel){
	session sql(sqlite3, "data/cbdata.db");
	std::string isAdmin;
	indicator ind;
	sql << "create table if not exists admins (channel, user, primary key (channel, user))";
	sql << "select user from admins where channel = :chan and user = :username",use(channel),use(nick),into(isAdmin, ind);
	if (sql.got_data()){
		std::cout << isAdmin << std::endl;
		switch(ind) {
			case i_ok:
				return true;
				break;
		}
	}
	else	
		return false;
}

void registerCommand(std::string command, std::string functionName, bool secured)
{
	commandList[command].func = functionName;
	commandList[command].secured = secured;
	std::cout << "Command " << command << " registered" << std::endl;
}
void registerCoreCommand(std::string command, void (*functionName)(std::vector<std::string> w, std::string s, IRCCommandPrefix p, IRCClient* c), bool secured) {
	coreCommandList[command].func = functionName;
	coreCommandList[command].secured = secured;
	std::cout << "Core command " << command << " registered" << std::endl;
}

void registerCommand_default(std::string command, std::string functionName)
{
	registerCommand(command,functionName);
}

void registerSieve(std::string functionName)
{
	sieveList.push_front(functionName);
	std::cout << "Sieve " << functionName << " registered" << std::endl;
}

void getHelp(std::vector<std::string> words, std::string channel, IRCCommandPrefix user, IRCClient* client) {
	std::string help = "Commands available: ";
	for (std::map<std::string,securedCommand>::const_iterator it = commandList.begin(); it != commandList.end(); it++)
		{
			bool secured = it->second.secured;
			if (!secured || (secured && getAdmin(user.nick, channel) || user.nick == getConfig("owner"))) {
				help.append(it->first);
				help.append(", ");
			}
		}
		for (std::map<std::string,securedCoreCommand>::const_iterator it = coreCommandList.begin(); it != coreCommandList.end(); it++)
		{
			bool secured = it->second.secured;
			if (!secured || (user.nick == getConfig("owner"))) {
				help.append(it->first);
				help.append(", ");
			}
		}
		help = help.erase(help.size() - 2,help.size());
		client->Send(user.nick, help);
}

void followInvite(IRCMessage message, IRCClient* client){
	client->Join(message.parameters.at(1));
}

void endMOTD(IRCMessage message, IRCClient* client){
	client->SendIRC("IDENTIFY " + getConfig("password"));
	client->SendIRC("MODE " + getConfig("nick") + " " + getConfig("modes"));
	session sql(sqlite3, "data/cbdata.db");
	rowset<row> rs = (sql.prepare << "select * from autojoins");
	for (rowset<row>::const_iterator it = rs.begin(); it != rs.end(); it++)
		{
			row const& row = *it;
			client->Join(row.get<std::string>(0));
		}
	
}