#pragma once
#include <string>
#include <vector>
#include <glob.h>
#include <boost/algorithm/string.hpp>
char* cstrc(std::string);
std::vector<std::string> glob(const std::string&);
std::vector<std::string> splitString(std::string, std::string);
std::string lower(std::string);