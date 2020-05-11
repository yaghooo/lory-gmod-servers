bash.exe -c "cargo build --release --out-dir ../bin/linux -Z unstable-options && exit"
cmd.exe /k "cargo build --release --out-dir ../bin/windows -Z unstable-options && exit"