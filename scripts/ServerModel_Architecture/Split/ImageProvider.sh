#! /bin/bash
# paths required to run cpp files
build_path=${BASE_DIR}/build_debwithrelinfo_gcc
image_path=${BASE_DIR}/data/ImageProvider
output_shares_path=${BASE_DIR}/data/ImageProvider/Final_Output_Shares
debug_ImageProv=${BASE_DIR}/logs/ImageProvider_logs/
smpc_config_path=${BASE_DIR}/config_files/smpc-remote-config.json
smpc_config=`cat $smpc_config_path`
#--------------------------- Inputs ------------------------------------------------------------#
# Do dns resolution or not 
cs0_dns_resolve=`echo $smpc_config | jq -r .cs0_dns_resolve`
cs1_dns_resolve=`echo $smpc_config | jq -r .cs1_dns_resolve`

# cs0_host is the ip/domain of server0, cs1_host is the ip/domain of server1
cs0_host=`echo $smpc_config | jq -r .cs0_host`
cs1_host=`echo $smpc_config | jq -r .cs1_host`

if [[ $cs0_dns_resolve == "true" ]];
then 
cs0_host=`dig +short $cs0_host | grep '^[.0-9]*$' | head -n 1`
fi

if [[ $cs1_dns_resolve == "true" ]];
then 
cs1_host=`dig +short $cs1_host | grep '^[.0-9]*$' | head -n 1`
fi

# Ports on which weights,image provider  receiver listens/talks
cs0_port_image_receiver=`echo $smpc_config | jq -r .cs0_port_image_receiver`
cs1_port_image_receiver=`echo $smpc_config | jq -r .cs1_port_image_receiver`   
# Ports on which Image provider listens for final inference output
cs0_port_cs0_output_receiver=`echo $smpc_config | jq -r .cs0_port_cs0_output_receiver`
cs0_port_cs1_output_receiver=`echo $smpc_config | jq -r .cs0_port_cs1_output_receiver`

fractional_bits=`echo $smpc_config | jq -r .fractional_bits`

# Index of the image for which inferencing task is run
image_id=`echo $smpc_config | jq -r .image_id`
#number of splits
splits=`echo "$smpc_config" | jq -r .splits`

if [ ! -d "$debug_ImageProv" ];
then
	# Recursively create the required directories
	mkdir -p $debug_ImageProv
fi

#---------------------------------- Starting the reverse ssh tunnel to send back the output shares from the servers to the image provider. ----------------#
# Assuming that the private key is iudx_cloud, which corresponds to the public key that is added to the analytics cloud vm for authentication.
# autossh -M 23323 -N -q -o "ExitOnForwardFailure yes"  -o "ServerAliveInterval 10" -o "ServerAliveCountMax 3" -R $cs0_port_cs0_output_receiver:localhost:$cs0_port_cs0_output_receiver sshtunuser@analytics.iudx.org.in -i ~/.ssh/iudx_cloud &

# autossh -M 23325 -N -q -o "ExitOnForwardFailure yes"  -o "ServerAliveInterval 10" -o "ServerAliveCountMax 3" -R $cs0_port_cs1_output_receiver:localhost:$cs0_port_cs1_output_receiver sshtunuser@analytics.iudx.org.in -i ~/.ssh/iudx_cloud &

#---------------------------------------------------------------------------------------------------------------------------------------------------------#
#--------------------------------------------- Image Share Provider -------------------------------------------------------#
# Create Image shares and send it to server 0 and server 1
echo "Image Provider starts"
$build_path/bin/image_provider_iudx --compute-server0-ip $cs0_host --compute-server0-port $cs0_port_image_receiver --compute-server1-ip $cs1_host --compute-server1-port $cs1_port_image_receiver --fractional-bits $fractional_bits --index $image_id --filepath $image_path > $debug_ImageProv/image_provider.txt &
pid1=$!
wait $pid1
echo "Image shares sent."
#------------------------------------------ Share generators end  ----------------------------------------------------------#

#------------------------------------------ Output share receivers ---------------------------------------------------------#
# Receiving the shares of the result from server 0 and server 1
$build_path/bin/output_shares_receiver --my-id 0 --listening-port $cs0_port_cs0_output_receiver --current-path $output_shares_path > $debug_ImageProv/output_shares_receiver0.txt &
pid5=$!

$build_path/bin/output_shares_receiver --my-id 1 --listening-port $cs0_port_cs1_output_receiver --current-path $output_shares_path > $debug_ImageProv/output_shares_receiver1.txt &
pid6=$!

echo "Image Provider is waiting for the inferencing result"
wait $pid5 $pid6

#-----------------------------------------     Reconstruction     -------------------------------------------------------#

echo "Reconstruction Starts"
$build_path/bin/Reconstruct --current-path $output_shares_path 
pid1=$!
wait $pid1

#----------------------------------- Stopping autossh ------------------------------------#
#echo "pkill -3:" > $debug_ImageProv/stop_autosshlogs.txt 
#pkill -3 autossh > $debug_ImageProv/stop_autosshlogs.txt
# echo "killall:" > $debug_ImageProv/stop_autosshlogs.txt  
# killall autossh >$debug_ImageProv/stop_autosshlogs.txt 
#------------------------------------------------------------------------------------------#
wait
