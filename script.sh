#!/usr/bin/bash
sc_revert() {
    echo -e "\e[38;5;214m\nReverting...\e[m"
    git restore . > /dev/null
    git clean . -f > /dev/null
    echo -e "Project initialization \e[5;31mUNSUCCESSFULL\e[m"
}

sc_final(){
    echo -e "\e[38;5;214m\nCommiting changes...\e[m"
    rm script.sh
    rm -r -f ./.git ./.github/
    (git init ;git add .;git commit -m "base commit") > /dev/null
    echo -e "\e[38;5;2m✓\e[m done\n\nRun \e[1;34;40m npm run serve \e[m to serve your application"
    echo -e "\n\e[38;5;2mSuccessfully initialised project\e[m 🎉🎉"
}

# only handling Ctrl+C for now
trap "echo -e '\n\n\e[7;31m X \e[m \e[38;5;1mencountered error:\e[m \e[4;31mSIGINT\e[m';sc_revert;exit $?" SIGINT

echo -e "\e[38;5;214m\nInstalling dependencies...\e[m"
npm i
echo -e "\e[38;5;2m✓\e[m done"

if [ $1 ]
then
    file=webpack.config.js
    echo -e "\e[38;5;214m\nInstalling typescript dependencies...\e[m"
    sed -e '26,35c \
	      {\
		    test: /\.(ts|tsx)$/i,\
		    exclude: /node_modules/,\
		    use: {\
			loader: "babel-loader",\
			options: {\
			    presets: [["@babel/preset-react"],\
			    ["@babel/preset-typescript", {\
				isTSX: true,\
				allExtensions: true\
			    }]]\
			},\
		    },\
	      },'\
	-e '50c\        extensions: [".ts", ".tsx", ".js"]'\
	-e '8s/\.js\(x\)\?/.ts\1/' < $file > tmp &&\
    rm $file;mv tmp $file &&\
    mv ./src/index.js ./src/index.ts;mv ./src/App.jsx ./src/App.tsx &&\
    npm i --save-dev typescript @babel/preset-typescript &&\
    npx tsc --init --jsx preserve
    echo -e "\e[38;5;2m✓\e[m done"
fi

if [ $? -eq 0 ]
then
    sc_final
else
    sc_revert
fi
