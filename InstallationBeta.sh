#All I needed to do was change if [ "$hwid_resp" != "true" ] to if [ "$hwid_resp" == "true" ] XD
#I optionally added some messages though

#!/bin/bash

main() {
    clear
    echo -e "Welcome to the Cracked MacSploit Experience!"
    echo -e "Sorry Nexus, but I'm broke! looks like you won't be taking my money."
    local architecture=$(arch)

    if [ "$architecture" == "arm64" ]
    then
        echo -e "Detected ARM64 Architecture."
    fi

    if [ ! -f /Library/Apple/usr/libexec/oah/libRosettaRuntime ]
    then
        echo -e "You need rosetta bludsky go and install that shi"
        softwareupdate --install-rosetta --agree-to-license
    fi

    echo -ne "Doing some random stuff cause why not..."
    curl -s "https://git.raptor.fun/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq
    
    curl -s "https://git.raptor.fun/sellix/hwid" -o "./hwid"
    chmod +x ./hwid
    
    local user_hwid=$(./hwid)
    local hwid_info=$(curl -s "https://git.raptor.fun/api/whitelist?hwid=$user_hwid")
    local hwid_resp=$(echo $hwid_info | ./jq -r ".success")
    rm ./hwid


    echo -e "Downloading Latest Roblox..."
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.raptor.fun/main/version.json")
    
    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
    if [ "$architecture" == "arm64" ]
    then
        if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
        then
            curl "http://setup.rbxcdn.com/mac/arm64/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        else
            curl "http://setup.rbxcdn.com/mac/arm64/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        fi
    else
        if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
        then
            curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        else
            curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
        fi
    fi
    
    echo -n "Installing Latest Roblox... "
    [ -d "./Applications/Roblox.app" ] && rm -rf "./Applications/Roblox.app"
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"

    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading MacSploit..."
    curl "https://git.raptor.fun/main/macsploit.zip" -o "./MacSploit.zip"
    unzip -o -q "./MacSploit.zip"
    rm ./MacSploit.zip

    echo -n "Updating Dylib..."
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        if [ "$architecture" == "arm64" ]
        then
            curl -Os "https://git.raptor.fun/preview/arm/macsploit.dylib"
        else
            curl -Os "https://git.raptor.fun/preview/main/macsploit.dylib"
        fi
    else
        if [ "$architecture" == "arm64" ]
        then
            curl -Os "https://git.raptor.fun/arm/macsploit.dylib"
        else
            curl -Os "https://git.raptor.fun/main/macsploit.dylib"
        fi
    fi
    
    echo -e " Done."
    echo -e "Patching Roblox..."

    if [ "$architecture" == "arm64" ]
    then
        codesign --remove-signature /Applications/Roblox.app
    fi

    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    if [ "$architecture" == "arm64" ]
    then
        echo -n "Signing MacSploit Installation... "
        codesign -s "-" /Applications/Roblox.app
        echo -e " Done."
    fi

    echo -e "Downloading MacSploit App..."
    [ -d "./Applications/MacSploit.app" ] && rm -rf "./Applications/MacSploit.app"
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    if [ "$architecture" == "arm64" ]
    then
        curl -O "https://git.raptor.fun/arm/ms-app.zip"
    else
        curl -O "https://git.raptor.fun/main/ms-app.zip"
    fi

    unzip -o -q "./ms-app.zip"
    mv ./ms-app.app /Applications/MacSploit.app
    rm ./ms-app.zip

    if [ ! -d "./Documents/MacsploitUI" ]
    then
        mkdir ./Documents/MacsploitUI
        curl -Os https://git.raptor.fun/main/scripts.zip
        unzip -o -q -d ./Documents/MacsploitUI ./scripts.zip
        rm ./scripts.zip
    fi
    
    touch ~/Downloads/ms-version.json
    echo $versionInfo > ~/Downloads/ms-version.json
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        cat <<< $(./jq '.channel = "previewb"' ~/Downloads/ms-version.json) > ~/Downloads/ms-version.json
    fi
    
    rm ./jq
    rm -r ./MacSploit.app
    echo -e "Done."
    echo -e "Install Complete! Developed by Nexus42!\nCracked by miles5746!"
    exit
}

main
