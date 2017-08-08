#LIPIDname=$(grep M_POPC_M ../mappingFILE.txt | awk '{printf "%5s\n",$2}')
#grep ' 1POPC' ../conf.gro | awk '{print $2}' > tmpEL.dat
#cat tmpEL.dat | awk '{if($0~"C") print $1" =6";if($0~"H") print $1" =1"; if($0~"H") print $1" =1"; if($0~"O") print $1" =8"; if($0~"P") print $1" =15"; if($0~"N") print $1" =7";}END{print "OW =6";print "HW1 =1";print "HW2 =1";} 
#' > electrons.dat
#Enumber=$(cat electrons.dat | awk '{sum=sum+1}END{print sum}')
#echo $Enumber >> tmp.dat
#cat electrons.dat >> tmp.dat 
#mv tmp.dat electrons.dat

mappingFILE='../../../mappingFILE.txt'

/mnt/ssd/MATCH-git/scripts/centerTheBilayer.sh $mappingFILE ../topol.tpr ../traj_openMM.dcd centered.xtc
cp ../../../electronsLIPID.dat ./electrons.dat
SOLname=$(grep M_SOL_M $mappingFILE | awk '{printf "%5s\n",$2}')
SOLname=SOL
echo $SOLname | gmx density -f centered.xtc -s ../topol.tpr -ei electrons.dat -dens electron -o electronDENSITYsol.xvg -xvg none -sl 100
LIPIDname=$(grep M_POPC_M $mappingFILE | awk '{printf "%5s\n",$2}')
LIPIDname=POPC
echo $LIPIDname | gmx density -f centered.xtc -s ../topol.tpr -ei electrons.dat -dens electron -o electronDENSITYlipid.xvg -xvg none -sl 100
#cp ../electronsCHOL.dat ./electrons.dat
#CHOLname=$(grep M_CHOL_M $mappingFILE | awk '{printf "%5s\n",$2}')
#echo $CHOLname | gmx density -f centered.xtc -s ../topol.tpr -ei electrons.dat -dens electron -o electronDENSITYchol.xvg -xvg none -sl 100
if [ -e "electronDENSITYchol.xvg" ];
then
    paste electronDENSITYsol.xvg electronDENSITYlipid.xvg electronDENSITYchol.xvg | awk '{print $1" "$2+$4+$6}' > electronDENSITY.xvg
else
    paste electronDENSITYsol.xvg electronDENSITYlipid.xvg | awk '{print $1" "$2+$4+$6}' > electronDENSITY.xvg
fi
echo $LIPIDname | gmx traj -f centered.xtc -s ../topol.tpr -com -ox com.xvg -xvg none
com=$(cat com.xvg | awk '{sum1=sum1+$4; sum=sum+1;}END{print sum1/sum}')
cat electronDENSITY.xvg | awk -v com=$com '{print $1-com" "$2}' > electronDENSITYcent.xvg

slice=$(cat electronDENSITY.xvg | awk '{if(NR==2) print $1}')
bulkDENS=$(tail -n 1 electronDENSITY.xvg | awk '{print $2}')
cat electronDENSITYcent.xvg | awk -v slice=$slice -v bulkDENS=$bulkDENS 'BEGIN{scale=0.01;}{for(q=0;q<1000;q=q+1){F[q]=F[q]+($2-bulkDENS)*cos(scale*q*$1)*slice;}}END{for(q=0;q<1000;q=q+1){print 0.1*q*scale" "0.01*sqrt(F[q]*F[q])
}}' > ../Form_Factor_From_Simulation.dat
cp electronDENSITYcent.xvg ../Electron_Density_From_Simulation.dat

