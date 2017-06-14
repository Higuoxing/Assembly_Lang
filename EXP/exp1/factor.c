#include <stdio.h>

void CalcNN(int n, char *pOut)
{
    if(n < 0 || n > 100 || pOut == NULL)
        return;

    if(n == 0 || n == 1) {
        pOut[0] = '1';
        pOut[1] = '\0';
        return;
    }

    int i = 0,j=0,k=0;

    int carry = 0;  
    int length = 1; 
    int temp = 0;  
    int a[1000] = {0};
    a[0] = 1;

    for(i = 2; i <= n; ++i)  {
        carry = 0;  
        for(j = 0; j < length; ++j) {
            temp = a[j] * i + carry; 
            a[j] = temp % 10;    
            carry = temp / 10;  
        }

        while(carry) {      
            a[length] = carry % 10;    
            length++; 
            carry /= 10;
        }
    }
    for(i = length - 1; i >= 0; i--) {
        pOut[k] = a[i] +'0';
        k++;
    }

    pOut[k] = '\0';

    return;
}

int main(void) 
{
		int input = 0;
		char output[10000];
		scanf("%d", & input);
		CalcNN(input, output);
		printf("%s",output);
		return 0;
}

