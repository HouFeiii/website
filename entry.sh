#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true  

bash "${STEAMCMDDIR}/steamcmd.sh" +login anonymous \
				+force_install_dir "${STEAMAPPDIR}" \
				+app_update "${STEAMAPPID}" \
				+quit

# We assume that if the config is missing, that this is a fresh container
if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg" ]; then
	# Download & extract the config
	wget -qO- "${DLURL}/master/etc/cfg.tar.gz" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
	
	# Are we in a metamod container?
	if [ ! -z "$METAMOD_VERSION" ]; then
		LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)
		wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"	
	fi

	# Are we in a sourcemod container?
	if [ ! -z "$SOURCEMOD_VERSION" ]; then
		LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
		wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
	fi

	# Change hostname on first launch (you can comment this out if it has done it's purpose)
	sed -i -e 's/{{SERVER_HOSTNAME}}/'"${SRCDS_HOSTNAME}"'/g' "${STEAMAPPDIR}/${STEAMAPP}/cfg/server.cfg"

	wget https://houyongfei:6ca9c88541e110946bf910451ceeabf1f69979e7@nanny.netease.com/houyongfei/csgo-community-server/raw/master/etc/unzip

	wget https://ptah.zizt.ru/files/PTaH-V1.1.3-build19-linux.zip
  unzip PTaH-V1.1.3-build19-linux.zip -d "${HOMEDIR}"


  wget -qO- https://github.com/kgns/gloves/archive/v1.0.3.tar.gz | tar xvzf - gloves-1.0.3/addons -C "${HOMEDIR}"
  wget -qO- https://github.com/kgns/weapons/archive/v1.7.0.tar.gz | tar xvzf - weapons-1.7.0/addons -C "${HOMEDIR}"
  wget -qO- https://github.com/kgns/gloves/archive/v1.0.3.tar.gz | tar xvzf - gloves-1.0.3/cfg -C "${HOMEDIR}"
  wget -qO- https://github.com/kgns/weapons/archive/v1.7.0.tar.gz | tar xvzf - weapons-1.7.0/cfg -C "${HOMEDIR}"

  cd "${HOMEDIR}"
  find addons -type d | xargs -I source_dir mkdir "${STEAMAPPDIR}/${STEAMAPP}"/source_dir
  find addons -type f | xargs -I source_file cp source_file "${STEAMAPPDIR}/${STEAMAPP}"/source_file

  cd "${HOMEDIR}"/gloves-1.0.3
  find . -type d | xargs -I source_dir mkdir "${STEAMAPPDIR}/${STEAMAPP}"/source_dir
  find . -type f | xargs -I source_file cp source_file "${STEAMAPPDIR}/${STEAMAPP}"/source_file

  cd "${HOMEDIR}"/weapons-1.7.0
  find . -type d | xargs -I source_dir mkdir "${STEAMAPPDIR}/${STEAMAPP}"/source_dir
  find . -type f | xargs -I source_file cp source_file "${STEAMAPPDIR}/${STEAMAPP}"/source_file

  sed -i -e '/FollowCSGOServerGuidelines/s/yes/no/g' "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/configs/core.cfg"

  # add sourcemod admin
	# we can add multi admin
	if [ ! -z "$SOURCEMOD_ADMIN" ]; then
	  read -a admins <<< "$SOURCEMOD_ADMIN"
	  for admin in ${admins}
	  do
	    echo \""${admin}"\" \"99:z\" >> "${STEAMAPPDIR}/${STEAMAPP}"/addons/sourcemod/configs/admins_simple.ini
	  done
	fi
fi

# Believe it or not, if you don't do this srcds_run shits itself
cd ${STEAMAPPDIR}

IFS='-'
read -a PORT <<< "${SRCDS_PORT}"
read -a TV_PORT <<< "${SRCDS_TV_PORT}"
read -a TOKEN <<< "${SRCDS_TOKEN}"
read -a MODE <<< "${SRCDS_GAMEMODE}"
read -a TYPE <<< "${SRCDS_GAMETYPE}"

NUM=${#PORT[@]}
echo "num $NUM" >> /home/steam/file.txt
for((i=0;i<${NUM};i++))
do
srcds_port=${PORT[i]}
srcds_tv_port=${TV_PORT[i]}
srcds_token=${TOKEN[i]}
srcds_gamemode=${MODE[i]}
srcds_gametype=${TYPE[i]}
bash "${STEAMAPPDIR}/srcds_run" -game "${STEAMAPP}" -console -autoupdate \
			-steam_dir "${STEAMCMDDIR}" \
			-steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt" \
			-usercon \
			+fps_max "${SRCDS_FPSMAX}" \
			-tickrate "${SRCDS_TICKRATE}" \
			-port "${srcds_port}" \
			+tv_port "${srcds_tv_port}" \
			+clientport "${SRCDS_CLIENT_PORT}" \
			-maxplayers_override "${SRCDS_MAXPLAYERS}" \
			+game_type "${srcds_gametype}" \
			+game_mode "${srcds_gamemode}" \
			+mapgroup "${SRCDS_MAPGROUP}" \
			+map "${SRCDS_STARTMAP}" \
			+sv_setsteamaccount "${srcds_token}" \
			+rcon_password "${SRCDS_RCONPW}" \
			+sv_password "${SRCDS_PW}" \
			+sv_region "${SRCDS_REGION}" \
			+net_public_adr "${SRCDS_NET_PUBLIC_ADDRESS}" \
			-ip "${SRCDS_IP}" \
			+host_workshop_collection "${SRCDS_HOST_WORKSHOP_COLLECTION}" \
			+workshop_start_map "${SRCDS_WORKSHOP_START_MAP}" \
			-authkey "${SRCDS_WORKSHOP_AUTHKEY}" \
			"${ADDITIONAL_ARGS}"\
			> /home/steam/"${srcds_port}".log 2>&1 &
done

while : 
do
sleep 1
done
