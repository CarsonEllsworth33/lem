int memory_length = 256;
char memory[memory_length]; 

void return_none () {
    int y = 1 + 1;
}

int main (int x) {
    return_none()
    while (x < memory_length) {
        y = memory [x % memory_length];
        x = x + 1;
    }
    return y;
}
