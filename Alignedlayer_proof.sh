#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Alignedlayer_proof.sh"

function install(){
    # 下载并安装 aligned
    curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/install_aligned.sh | bash

    # 加载 .bashrc 文件
    source /root/.bashrc

    # 等待5秒
    sleep 10

    # 检查 .bashrc 是否加载成功
    if echo "$PATH" | grep -q "/root/.aligned/bin"; then
        echo ".bashrc 文件加载成功"
    else
        echo ".bashrc 文件加载失败,请手动执行 source /root/.bashrc" >&2
    fi

    # 下载证明测试文件
    if curl -L https://raw.githubusercontent.com/yetanotherco/aligned_layer/main/batcher/aligned/get_proof_test_files.sh | bash; then
        echo "证明测试文件下载成功"
    else
        echo "证明测试文件下载失败" >&2
    fi
}

function proof(){

    # 提交证明
    if aligned submit --proving_system SP1 --proof ~/.aligned/test_files/sp1_fibonacci.proof --vm_program ~/.aligned/test_files/sp1_fibonacci-elf --aligned_verification_data_path ~/aligned_verification_data --conn wss://batcher.alignedlayer.com; then
        echo "证明提交成功"
    else
        echo "证明提交失败" >&2
    fi

}

function verify(){

# 在链上验证证明
verify_output=$(aligned verify-proof-onchain --aligned-verification-data ~/aligned_verification_data/*.json --rpc https://ethereum-holesky-rpc.publicnode.com --chain holesky 2>&1)
echo "${verify_output}"
if echo "$verify_output" | grep -q "Your proof was not included in the batch"; then
    echo "证明在链上验证失败: Your proof was not included in the batch" >&2
    exit 1
elif echo "$verify_output" | grep -q "Your proof was verified"; then
    echo "证明在链上验证成功，请保存好该链接"
else
    echo "证明在链上验证失败: 其他错误" >&2
    exit 1
fi

}

function delete(){

rm -rf $HOME/aligned_verification_data
echo "Proof证明清除成功"
}

# 主菜单
function main_menu() {
    clear
    echo "==============================自用脚本=================================="
    echo "Discord链接：https://t.co/rQmFr0Fcio"
    echo "推特发文格式：  #aligned✅:证明链接   "
    echo "请选择要执行的操作:"
    echo "1. 安装Alignedlayer Proof证明(接受手动执行source /root/.bashrc)"
    echo "2. 执行Proo证明(请保存好链接通过推特发文 将推特发文链接发送到dc中的testnet频道)"
    echo "3. 验证Proof（执行Proo证明后 等待5分钟再验证）"
    echo "4. 清除证明数据"
    
    read -p "请输入选项（1-4）: " OPTION

    case $OPTION in
    1) install ;;
    2) proof ;;
    3) verify ;;  
    4) delete ;;
    *) echo "无效选项。" ;;
    esac
}

# 显示主菜单
main_menu
