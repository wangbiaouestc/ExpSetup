echo "disable frequency scaling not working with intel_pstate driver, as it doesn't provide userspace governor"
echo "to enable userspace mode, you should use the older driver acpi-cpufreq, which is enabled automatically when intel_pstate is disabled"
echo "Do following to disable intel_pstate"
echo "1. sudo vim /etc/default/grub"
echo "2. add option to intel_pstate=disable to variable GRUB_CMDLINE_LINUX_DEFAULT"
echo "   .eg GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_pstate=disable""
echo "3. sudo update-grub"
echo "4. sudo reboot"
echo "5. sudo modprobe cpufreq_userspace"
echo "6. sudo cpupower frequency-set --governor userspace"
echo "7. sudo cpupower frequency-set --freq 2.3GHz"
echo "8. sudo cpupower frequency-info"

#Get the number of CPUs
NUMCPUS=`cat /proc/cpuinfo|grep processor|wc -l`
NUMCPUSMINUS1=`expr $NUMCPUS - 1`

echo In This machine `hostname` we have $NUMCPUS CPUs
#set the governor as performance

sudo modprobe cpufreq_userspace
sudo cpupower frequency-set --governor userspace
sudo cpupower frequency-set --freq 2.3GHz
sudo cpupower frequency-info

echo disable the Turbo boost
sudo apt-get install msr-tools -y
modloaded=`lsmod|grep mod`

if [ -z $modloaded ]
then
    sudo modprobe msr
fi

for cpu in `seq 0 $NUMCPUSMINUS1`
do 
    turbostatebit=`sudo rdmsr -p$cpu 0x1a0 -f 38:38`
    echo 
    if [ $turbostatebit -eq 0 ]
       then
       sudo wrmsr -p $cpu 0x1a0 0x4000850089
       turbostatebit=`sudo rdmsr -p$cpu 0x1a0 -f 38:38`
       if [ $turbostatebit -eq 0 ]
       then
            echo "I try to disable turbo, but not working" 
       fi
    fi      
done

echo Turbo Boost disabled
