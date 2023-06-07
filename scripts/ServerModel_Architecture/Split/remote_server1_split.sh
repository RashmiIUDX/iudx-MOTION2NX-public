#!/bin/bash
check_exit_statuses() {
   for status in "$@";
   do
      if [ $status -ne 0 ]; then
         echo "Exiting due to error."
         exit 1  # Exit the script with a non-zero exit code
      fi
   done
}
image_config=${BASE_DIR}/config_files/file_config_input_remote
model_config=${BASE_DIR}/config_files/file_config_model
build_path=${BASE_DIR}/build_debwithrelinfo_gcc
debug_1=${BASE_DIR}/logs/server1/
smpc_config_path=${BASE_DIR}/config_files/smpc-remote-config.json
smpc_config=`cat $smpc_config_path`
# #####################Inputs##########################################################################################################
# Do dns resolution or not 
cs0_dns_resolve=`echo $smpc_config | jq -r .cs0_dns_resolve`
cs1_dns_resolve=`echo $smpc_config | jq -r .cs1_dns_resolve`
reverse_ssh_dns_resolve=`echo $smpc_config | jq -r .reverse_ssh_dns_resolve`

# cs0_host is the ip/domain of server0, cs1_host is the ip/domain of server1
cs0_host=`echo $smpc_config | jq -r .cs0_host`
cs1_host=`echo $smpc_config | jq -r .cs1_host`
reverse_ssh_host=`echo $smpc_config | jq -r .reverse_ssh_host`

if [[ $cs0_dns_resolve == "true" ]];
then 
cs0_host=`dig +short $cs0_host | grep '^[.0-9]*$' | head -n 1`
fi

if [[ $cs1_dns_resolve == "true" ]];
then 
cs1_host=`dig +short $cs1_host | grep '^[.0-9]*$' | head -n 1`
fi

if [[ $reverse_ssh_dns_resolve == "true" ]];
then 
reverse_ssh_host=`dig +short $reverse_ssh_host | grep '^[.0-9]*$' | head -n 1`
fi

# Ports on which weights,image provider  receiver listens/talks
cs1_port_model_receiver=`echo $smpc_config | jq -r .cs1_port_model_receiver`
cs1_port_image_receiver=`echo $smpc_config | jq -r .cs1_port_image_receiver`     

# Port on which final output talks to image provider 
cs0_port_cs1_output_receiver=`echo $smpc_config | jq -r .cs0_port_cs1_output_receiver`


# Ports on which server0 and server1 of the inferencing tasks talk to each other
cs0_port_inference=`echo $smpc_config | jq -r .cs0_port_inference`
cs1_port_inference=`echo $smpc_config | jq -r .cs1_port_inference`
relu0_port_inference=`echo $smpc_config | jq -r .relu0_port_inference`
relu1_port_inference=`echo $smpc_config | jq -r .relu1_port_inference`
fractional_bits=`echo $smpc_config | jq -r .fractional_bits`

#number of splits
splits=`echo "$smpc_config" | jq -r .splits`

if [ ! -d "$debug_1" ];
then
	mkdir -p $debug_1
fi

cd $build_path


if [ -f finaloutput_1 ]; then
   rm finaloutput_1
   # echo "final output 1 is removed"
fi

if [ -f MemoryDetails1 ]; then
   rm MemoryDetails1
   # echo "Memory Details1 are removed"
fi

if [ -f AverageMemoryDetails1 ]; then
   rm AverageMemoryDetails1
   # echo "Average Memory Details1 are removed"
fi
if [ -f AverageMemory1 ]; then
   rm AverageMemory1
   # echo "Average Memory Details1 are removed"
fi

if [ -f AverageTimeDetails1 ]; then
   rm AverageTimeDetails1
   # echo "AverageTimeDetails1 is removed"
fi

if [ -f AverageTime1 ]; then
   rm AverageTime1
   # echo "AverageTime1 is removed"
fi

#########################Weights Share Receiver ############################################################################################
echo "Weight shares receiver starts"
$build_path/bin/Weights_Share_Receiver_remote --my-id 1 --port $cs1_port_model_receiver --file-names $model_config --current-path $build_path > $debug_1/Weights_Share_Receiver0.txt &
pid1=$!

#########################Image Share Receiver ############################################################################################
echo "Image shares receiver starts"
$build_path/bin/Image_Share_Receiver --my-id 1 --port $cs1_port_image_receiver --fractional-bits $fractional_bits --file-names $image_config --current-path $build_path > $debug_1/Image_Share_Receiver.txt &
pid2=$!
wait $pid2
check_exit_statuses $? 
wait $pid1
check_exit_statuses $?
echo "Weight shares received"
echo "Image shares received"
#########################Share receivers end ############################################################################################

########################Inferencing task starts ###############################################################################################

echo "Inferencing task of the image starts"
echo "Number of splits for layer 1 matrix multiplication - $splits"
x=$((256/splits))
 
############################Inputs for inferencing tasks #######################################################################################
 for  (( m = 1; m <= $splits; m++ )) 
  do 
   layer_id=1
   input_config=" "
   image_share="remote_image_shares"
   if [ $layer_id -eq 1 ];
   then
      input_config="remote_image_shares"
   fi
   let l=$((m-1)) 
   let a=$(((m-1)*x+1)) 
   let b=$((m*x)) 
   let r=$((l*x)) 

#######################################Matrix multiplication layer 1 ###########################################################################

   #Layer 1   
   $build_path/bin/tensor_gt_mul_split --my-id 1 --party 0,$cs0_host,$cs0_port_inference --party 1,$cs1_host,$cs1_port_inference --arithmetic-protocol beavy --boolean-protocol yao --fractional-bits 13 --config-file-input $input_config --config-file-model file_config_model1 --layer-id $layer_id --row_start $a --row_end $b --split $splits --current-path $build_path  > $debug_1/tensor_gt_mul1_layer1_split.txt &
   pid3=$!
   wait $pid3  
   check_exit_statuses $?
   echo "Layer 1, split $m: Matrix multiplication and addition is done"
   
   if [ $m -eq 1 ];then
      touch finaloutput_1
      printf "$x 1\n" >> finaloutput_1
      $build_path/bin/appendfile 1
      pid4=$!
      wait $pid4 
      check_exit_statuses $?
   else 
      
      $build_path/bin/appendfile 1
      pid5=$!
      wait $pid5 
      check_exit_statuses $?
   fi

		sed -i "1s/${r} 1/${b} 1/" finaloutput_1
 done

cp finaloutput_1  $build_path/server1/outputshare_1
check_exit_statuses $?
#######################################ReLu layer 1 ####################################################################################
$build_path/bin/tensor_gt_relu --my-id 1 --party 0,$cs0_host,$relu0_port_inference --party 1,$cs1_host,$relu1_port_inference --arithmetic-protocol beavy --boolean-protocol yao --fractional-bits $fractional_bits --filepath file_config_input1 --current-path $build_path > $debug_1/tensor_gt_relu1_layer1.txt &
pid6=$!
wait $pid6
check_exit_statuses $?
echo "Layer 1: ReLU is done"

#######################Next layer, layer 2, inputs for layer 2 ###################################################################################################
((layer_id++))

#Updating the config file for layers 2 and above. 
if [ $layer_id -gt 1 ];
then
    input_config="outputshare"
fi

#######################################Matrix multiplication layer 2 ###########################################################################
$build_path/bin/tensor_gt_mul_test --my-id 1 --party 0,$cs0_host,$cs0_port_inference --party 1,$cs1_host,$cs1_port_inference --arithmetic-protocol beavy --boolean-protocol yao --fractional-bits $fractional_bits --config-file-input $input_config --config-file-model file_config_model1 --layer-id $layer_id --current-path $build_path > $debug_1/tensor_gt_mul1_layer2.txt &
pid7=$!
wait $pid7
check_exit_statuses $?
echo "Layer 2: Matrix multiplication and addition is done"

####################################### Argmax  ###########################################################################

$build_path/bin/argmax --my-id 1 --threads 1 --party 0,$cs0_host,$cs0_port_inference --party 1,$cs1_host,$cs1_port_inference --arithmetic-protocol beavy --boolean-protocol beavy --repetitions 1 --config-filename file_config_input1 --config-input $image_share --current-path $build_path  > $debug_1/argmax1_layer2.txt &
pid8=$!
wait $pid8
check_exit_statuses $?
echo "Layer 2: Argmax is done"

####################################### Final output provider  ###########################################################################

$build_path/bin/final_output_provider --my-id 1 --connection-port $cs0_port_cs1_output_receiver --connection-ip $reverse_ssh_host --config-input $image_share --current-path $build_path > $debug_1/final_output_provider1.txt &
pid9=$!
wait $pid9
check_exit_statuses $?
echo "Output shares of server 1 sent to the Image provider"

wait 

awk '{ sum += $1 } END { print sum }' AverageTimeDetails1 >> AverageTime1
#  > AverageTimeDetails1 #clearing the contents of the file

sort -r -g AverageMemoryDetails1 | head  -1 >> AverageMemory1
#  > AverageMemoryDetails1 #clearing the contents of the file

echo -e "Inferencing Finished"

Mem=`cat AverageMemory1`
Time=`cat AverageTime1`

Mem=$(printf "%.2f" $Mem) 
Convert_KB_to_GB=$(printf "%.14f" 9.5367431640625E-7)
Mem2=$(echo "$Convert_KB_to_GB * $Mem" | bc -l)

Memory=$(printf "%.3f" $Mem2)

echo "Memory requirement:" `printf "%.3f" $Memory` "GB"
echo "Time taken by inferencing task:" $Time "ms"

cd $scripts_path