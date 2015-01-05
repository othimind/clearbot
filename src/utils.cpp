#include "utils.hpp"

char* cstrc(std::string s){
	return strcpy((char*)malloc(s.length()+1), s.c_str());
}

std::vector<std::string> glob(const std::string& pat){
    using namespace std;
    glob_t glob_result;
    glob(pat.c_str(),GLOB_TILDE,NULL,&glob_result);
    vector<string> ret;
    for(unsigned int i=0;i<glob_result.gl_pathc;++i){
        ret.push_back(string(glob_result.gl_pathv[i]));
    }
    globfree(&glob_result);
    return ret;
}

std::vector<std::string> splitString(std::string s, std::string delimiter) {
	std::vector<std::string> result;
	boost::split(result,s, boost::is_any_of(delimiter), boost::token_compress_on);
	return result;
}

std::string lower(std::string s){
	boost::algorithm::to_lower(s);
	return s;
}