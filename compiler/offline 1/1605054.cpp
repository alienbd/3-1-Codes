#include<bits/stdc++.h>
#define inf 0x7fffffff

using namespace std;


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

    long long hashFunc(string const& s)
    {
        const int p = 31;
        const int m = 1e9 + 9;
        long long hash_value = 0;
        long long p_pow = 1;
        for (char c : s)
        {
            if(c>='A' && c<='Z') c = c-'A'+'a';
            else if(c>='0' && c<='9') c = c-'0'+'a';
            hash_value = (hash_value + (c - 'a' + 1) * p_pow) % m;
            p_pow = (p_pow * p) % m;
        }
        return hash_value;
    }

    int getHashValue(string str)
    {
        //transform(str.begin(), str.end(), str.begin(), ::tolower);
        long long hv = hashFunc(str);
        int hashValue = hv % capacity;
        return hashValue;
    }

    symbolInfo* lookUp(string name,int flag=0)
    {
        int position = 0;
        int hashValue = getHashValue(name);

        symbolInfo *temp ;

        temp = &slist[hashValue];

        while(temp->next != nullptr)
        {
            temp = temp->next;
            position++;
            //temp->print();
            if(temp->getName() == name)
            {
                if(flag == 0) cout<<"Found in ScopeTable# 1 at position "<<hashValue<<", "<<position<<endl;
                //temp->print();
                return temp;
            }
            //cout<<endl;
        }

        if(temp->next == nullptr)
        {
            if(flag == 0) cout<<"ITEM NOT FOUND";
            return nullptr;
        }

    }

    void insert(string name,string type)
    {
        int position = 0;
        symbolInfo *newItem = new symbolInfo();
        symbolInfo *temp ;

        temp = lookUp(name,1);

        if(temp != nullptr )
        {
            cout<<"ITEM ALREADY EXIST"<<endl;
            //cout<<"item: ";
            //temp->print();
            //cout<<endl;
            return ;
        }

        int hashValue = getHashValue(name);

        temp = &slist[hashValue];

        //cout<<name<<" "<<type<<endl;
        newItem->setName(name);
        newItem->setType(type);
        //newItem->print();

        while(temp->next != nullptr)
        {
            temp = temp->next;
            position++;
        }
        temp->next = newItem;
        cout<<"\tInserted in ScopeTable# 1 at position "<< hashValue<<", "<<position<<endl;
        //slist->next->print();
    }

    void Delete(string name)
    {
        int hashValue = getHashValue(name);

        symbolInfo *temp ;

        temp = &slist[hashValue];

        while(temp->next != nullptr)
        {
            if(temp->next->getName() == name){
                temp->next = temp->next->next;
                return ;
            }
            temp = temp->next;
        }

        if(temp->next == nullptr)
        {
            cout<<"ITEM NOT FOUND";
        }

    }

    void print()
    {
        symbolInfo * temp;

        for(int i=0; i<capacity; i++)
        {
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
    cin>>n>>m;

    scopeTable st(m);

    for(int i=0; i<n; i++)
    {
        string command,name,type;
        cin>>command>>name>>type;


        st.insert(name,type);
    }

    st.print();
    cout<<endl;

    st.lookUp("foo");
    st.lookUp("5");
    st.lookUp("alien");

    st.Delete("foo");
    st.print();
    cout<<endl;
    st.Delete("A");
    st.print();
    cout<<endl;
    st.Delete("alien");
    st.print();
    cout<<endl;
    return 0;
}


/*
    st.lookUp("foo");
    st.lookUp("5");
    st.lookUp("alien");

*/
