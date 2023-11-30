#!/usr/bin/bash
sc_revert() {
    echo -e "\e[38;5;214m\nReverting...\e[m"
    git restore . > /dev/null
    git clean . -f > /dev/null
    echo -e "Conversion to typescript \e[5;31mUNSUCCESSFULL\e[m"
}

sc_final(){
    rm script.sh
    echo -e "\e[38;5;214m\nCommiting changes...\e[m"
    git commit -am "added typescript" > /dev/null
    echo -e "\n\e[38;5;2mSuccessfully initialised typescript\e[m 🎉🎉"

}

# only handling Ctrl+C for now
trap "echo -e '\n\n\e[7;31m X \e[m \e[38;5;1mencountered error:\e[m \e[4;31mSIGINT\e[m';sc_revert;exit $?" SIGINT

file=webpack.config.js
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
echo -e "\e[38;5;214m\nCommiting changes...\e[m" &&\
npm i --save-dev typescript @babel/preset-typescript &&\
npx tsc --init

if [ $? -eq 0 ]
then
    sc_final
else
    sc_revert
fi
