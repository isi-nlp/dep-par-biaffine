#!/bin/bash

set -e

il=$1
use_we=$2  # guo, muse
clt_opt=$3 # id, emb
tr_pos=$4  # gold, unk

exp_id="$il-$use_we-$clt_opt-$tr_pos"
outfile="$il".$use_we.$clt_opt.$tr_pos.sh


unk_pos_opt="False"

if [ $tr_pos = "unk" ]; then
	unk_pos_opt="True"
fi


echo "#!/bin/bash" > $outfile
echo "#SBATCH --ntasks=40" >> $outfile
echo "#SBATCH --mem=40GB" >> $outfile
echo "#SBATCH --mem-per-cpu=2GB" >> $outfile
echo "#SBATCH --gres=gpu:p100:1" >> $outfile
echo "#SBATCH --time=150:00:00" >> $outfile
echo "#SBATCH --partition=isi" >> $outfile
echo "" >> $outfile
echo "cd /home/rcf-40/rac_815/dep-par-biaffine/" >> $outfile
echo "source /home/rcf-40/rac_815/.bash_profile" >> $outfile
echo "" >> $outfile



echo "exp_id=$exp_id" >> $outfile
echo "" >> $outfile

test_orig="test.lc.lid"

# malopa original
cat ../config/tmp.baseline.cfg | \
sed "s/il-id/$il/" | \
sed "s/exp-dir/$exp_id/" | \
sed "s/clt-opt/$clt_opt/" | \
sed "s/we-opt/$use_we/" | \
sed "s/unk-pos-opt/$unk_pos_opt/" | \
sed "s/test-file/$test_orig/" \
> ../config/$exp_id.cfg

# malopa - cipher
cat ../config/tmp.baseline.cfg | \
sed "s/il-id/$il/" | \
sed "s/exp-dir/$exp_id/" | \
sed "s/clt-opt/$clt_opt/" | \
sed "s/we-opt/$use_we/" | \
sed "s/unk-pos-opt/$unk_pos_opt/" | \
sed "s/test-file/test.conllu.cipher/" \
> ../config/$exp_id.cipher.cfg


mkdir -p ../saves/$exp_id

echo 'python network.py --config_file config/$exp_id.cfg > saves/$exp_id/train.log' >> $outfile
