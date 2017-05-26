#! /usr/bin/env bash
## run_chipseq_vanilla.sh
## copyleft (c) Ren Lab 2017
## GNU GPLv3 License
############################


function usage(){
echo -e "Usage: $0 -g genome -e E-mail"
exit 1
}

while getopts "g:e:" OPT
do
  case $OPT in 
    g) genome=$OPTARG;;
    e) email=$OPTARG;;
    \?) 
      echo "Invalid option: -$OPTARG" >& 2
      usage
      exit 1;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        usage
        exit 1
        ;;
  esac
done

if [ $# -eq 0 ]; then usage; exit; fi
if [ -z ${email+x} ]; then echo -e "Please provide E-mail"; usage; exit; fi
if [ -z ${genome+x} ]; then echo -e "Please provide genome, eg. mm10, hg19"; usage;exit; fi


NTHREADS=12
DIR=$(dirname $0)
## validate the programs are installed.
. ${DIR}/validate_programs.sh
## load snakemake environment for Renlab
source /mnt/silencer2/share/Piplines/environments/python3env/bin/activate

echo "$(date) # Analysis Began" > run.log
snakemake -p --snakefile ${DIR}/Snakefile --cores $NTHREADS --config GENOME=$genome EMAIL=$email --keep-going 2> >(tee -a run.log >&2) 
echo "$(date) # Analysis finished" >> run.log

echo "See attachment for the running log. 
Your results are saved in: 
$(pwd)"  | mail -s "ChIP-seq analysis Done" -a run.log  $email
