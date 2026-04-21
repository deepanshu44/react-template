#!/bin/bash
sc_revert() {
    echo -e "\e[38;5;214m\nReverting...\e[m"
    git restore . > /dev/null
    git clean . -f > /dev/null
    echo -e "Project initialization \e[5;31mUNSUCCESSFULL\e[m"
}

sc_final(){
    echo -e "\e[38;5;214m\nCommiting changes...\e[m"
    rm script.sh README.md
    rm -r -f ./.git ./.github/
    (git init ;git add .;git commit -m "base commit") > /dev/null
    echo -e "\e[38;5;2m✓\e[m done\n\nRun \e[1;34;40m npm run serve \e[m to serve your application"
    echo -e "\n\e[38;5;2mSuccessfully initialised project\e[m 🎉🎉"
}

# only handling Ctrl+C for now
trap "echo -e '\n\n\e[7;31m X \e[m \e[38;5;1mencountered error:\e[m \e[4;31mSIGINT\e[m';sc_revert;exit $?" SIGINT

read -p "Enter new project name: " new_name
sed -i "s/\"name\": \".*\",/\"name\": \"$new_name\",/" package.json

echo -e "Do you want install \e[0;103;30mJavascript\e[m (j) or \e[48;5;27m\e[38;5;15mTypescript\e[m (t) ? \e[38;5;67m(default: javascript)\e[m"
read -r sc_lang
sc_project=$(echo $sc_lang | grep -i "^t")

if [ $sc_project ]
then
    file=webpack.config.js
    echo -e "\e[38;5;214m\nInstalling \e[48;5;27m\e[38;5;15mTypescript\e[m...\e[m"
    npm i
    sed -e '31,40c \
	            {\
	                test: /\\.(ts|tsx)$/i,\
	                exclude: /node_modules/,\
	                use: {\
	                    loader: "babel-loader",\
	                    options: {\
	                        presets: [\
	                            ["@babel/preset-react"],\
	                            ["@babel/preset-typescript", {\
	                                isTSX: true,\
	                                allExtensions: true\
	                            }]\
	                        ]\
	                    },\
	                },\
	            },' \
	-e '55c\    	extensions: [".ts", ".tsx", ".js"]' \
	-e '13s/\.js/.tsx/' \
	< $file > tmp &&\
    rm $file;mv tmp $file &&\
    file=eslint.config.js &&\
    sed -e '51s/\.jsx/.tsx/' < $file > tmp &&\
    rm $file;mv tmp $file &&\
    file=./src/index.js &&\
    sed -e 's/\.jsx//' < $file > tmp &&\
    rm $file;mv tmp $file &&\
    mv ./src/index.js ./src/index.tsx;mv ./src/App.jsx ./src/App.tsx &&\
    npm i --save-dev typescript @babel/preset-typescript &&\
    npx tsc --init --jsx preserve &&\
    echo -e "\e[38;5;2m✓\e[m done"
else
    echo -e "\e[38;5;214m\nInstalling \e[0;103;30mJavascript\e[m...\e[m"
    npm i
    echo -e "\e[38;5;2m✓\e[m done"
fi

if [ $? -eq 0 ]
then
    sc_final
else
    sc_revert
fi
