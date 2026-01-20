BEGIN { printf "byte data[] = {" }
NF != 1 {
    printf "\n  "
    for (i=2;i<18;i++) {
        if ($i !~ /[0-9a-f][0-9a-f]/ ) next
        printf i == 2 ? "0x%s, " : "0x%s, ", $i
    }
}
END { printf "\n};\n" }
