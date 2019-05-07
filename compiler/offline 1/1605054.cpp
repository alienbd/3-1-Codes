#include<bits/stdc++.h>
#define inf 0x7fffffff

using namespace std;

long long hashFunc(string const& s) {
    const int p = 31;
    const int m = 1e9 + 9;
    long long hash_value = 0;
    long long p_pow = 1;
    for (char c : s) {
        hash_value = (hash_value + (c - 'a' + 1) * p_pow) % m;
        p_pow = (p_pow * p) % m;
    }
    return hash_value;
}

class symbolInfo
{
    string name;
    string type;

public:
    symbolInfo *next;

    symbolInfo()
    {
        this->next = nullptr;
    }
    string getName()
    {
        return this->name;
    }

    string getType()
    {
        return this->type;
    }

    void setName(string n)
    {
        this->name = n;
    }

    void setType(string t)
    {
        this->type = t;
    }

    void print()
    {
        cout<<"<"<<this->name<<":"<<this->type<<">\t";
    }


};

class scopeTable
{
    int capacity;
    symbolInfo *slist;

public:
    scopeTable(int cap)
    {
        capacity = cap;
        slist = new symbolInfo[capacity];
    }

    void insert(string name,string type,int m)
    {
        symbolInfo *newItem = new symbolInfo();
        symbolInfo *temp ;

        temp = &slist[m];

        //cout<<name<<" "<<type<<endl;
        newItem->setName(name);
        newItem->setType(type);
        //newItem->print();

        while(temp->next != nullptr)
        {
            temp = temp->next;
        }
        temp->next = newItem;
        //slist->next->print();
    }

    void print()
    {
        symbolInfo * temp;

        for(int i=0;i<capacity;i++){
            temp = &slist[i];
            cout<<"hash table: "<<i<<"-->  ";
            while(temp->next != nullptr)
            {
                temp = temp->next;
                temp->print();
            }
            cout<<endl;
        }
    }
};

int main()
{
    //freopen("input.txt","r",stdin);
    //freopen("output.txt","w",stdout);
    ios_base::sync_with_stdio(0);
    int n,m,hashValue;
    long long hv;
    cin>>n>>m;
    scopeTable st(m);

    for(int i=0; i<n; i++)
    {
        string command,name,type,namelower;
        cin>>command>>name>>type;
        namelower = name;
        //cout<<command<<" "<<name<<" "<<type<<endl;


        transform(namelower.begin(), namelower.end(), namelower.begin(), ::tolower);
        hv = hashFunc(namelower);
        hashValue = hv % m;
        //cout<<hashValue<<endl;

        st.insert(name,type,hashValue);
    }

    st.print();



    return 0;
}
