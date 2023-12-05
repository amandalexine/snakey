#include <iostream>
#include <fstream>
#include <string>
#include <stdlib.h>

using namespace std;

string decimal_to_binary(int n);
string color_bin(int n);

int main()
{   
    //create the color scheme (randomly assigned - comment out)
    string color;
    string arr[100];
    for(int i = 0; i < 100; i++)
    {
        if(i < 64)
        {
            arr[i] = color_bin(i);
        }
        else
        {
            arr[i] = color_bin(i-64);
        }
        
        //cout << color << endl;
    }

    //create the rows and column addresses
    string row;
    string column;
    for(int i = 0; i < 100; i++)
    {
        row = decimal_to_binary(i);
        for(int j = 0; j < 100; j++)
        {
            column = decimal_to_binary(j);
            cout << "when \"" << row << column << "\"";
            cout << " => rgb <= \"" << arr[i] << "\";" << endl;
            //cout << " => rgb <= \"" << "000111" << "\";" << endl;
        }
    }
    cout << "when others";
    cout << " => rgb <= \"000000\";" << endl;

    return 0;
}

//only call this function if you want to randomly assign colors!!!
string color_bin(int n)
{
    int arr[6] = {0};

    for(int i = 0; i < 6; i++)
    {
        arr[i] = n%2;
        n = n/2;
    }
    string color = "";
    for(int i = 5; i >= 0; i--)
    {
        color = color + to_string(arr[i]);
    }

    return color;
}

//binary conversion function
string decimal_to_binary(int n)
{
    int arr[10] = {0};

    for(int i = 0; i < 10; i++)
    {
        arr[i] = n%2;
        n = n/2;
    }
    string bin = "";
    for(int i = 9; i >= 0; i--)
    {
        bin = bin + to_string(arr[i]);
    }

    return bin;
}
