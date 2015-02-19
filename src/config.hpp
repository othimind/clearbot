#pragma once
#include <fstream>
#include "utils.hpp"
#include "globals.hpp"
void loadConfig();
std::string getAPIKey(std::string);
std::string getConfig(std::string);
char* getConfigC(std::string);
