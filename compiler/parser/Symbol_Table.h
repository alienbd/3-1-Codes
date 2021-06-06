#include<bits/stdc++.h>
#define inf 0x7fffffff

using namespace std;

extern int scopeCount;

class functionInfo;

class symbolInfo
{
    string name;
    string type;
    string variableType;

public:
    FILE *fp;
    bool isFunc;
    bool isDef;
    functionInfo* funcInfo;

    symbolInfo *next;

    symbolInfo()
    {
        isFunc = false;
        isDef = false;
        this->next = NULL;
    }
    string getName()
    {
        return this->name;
    }

    string getType()
    {
        return this->type;
    }

    string getVariableType()
    {
        return this->variableType;
    }

    bool isFunction()
    {
        return isFunc;
    }

    bool isDefined()
    {
        return isDef;
    }

    functionInfo* getFunctionInfo()
    {
        return funcInfo;
    }

    void setName(string n)
    {
        this->name = n;
        //cout<<n<<"printing from symbol table"<<endl;
    }

    void setType(string t)
    {
        this->type = t;
    }

    void setVariableType(string t)
    {
        this->variableType = t;
    }

    void setIsFunction(bool b)
    {
        this->isFunc = b;
    }

    bool setIsDefined(bool b)
    {
        if(this->isFunc == true)
        {
            this->isDef = b;
        }
        else
        {
            this->isDef = false;
        }
        
    }

    void setFunctionInfo(functionInfo* f)
    {
        this->funcInfo = f;
    }

    void print(FILE *INP)
    {
        fp = INP;
        fprintf(fp,"< %s:%s >\t",this->name.c_str(),this->type.c_str());
        cout<<"< "<<this->name<<":"<<this->type<<" >\t";
    }


};

class functionInfo
{
    string returnType;
    int numberOfParam;
    vector< symbolInfo* >paramList;

public:


    string getReturnType()
    {
        return returnType;
    }

    vector< symbolInfo* > getParamList()
    {
        return  paramList;
    }

    int getNumberOfParam()
    {
        return numberOfParam;
    }

    void setReturnType(string t)
    {
        this->returnType = t;
    }

    void setParamList(vector<symbolInfo *> p)
    {
        this->paramList = p;
    }

    void setNumberOfParam()
    {
        this->numberOfParam = paramList.size();
    }


};
class scopeTable
{
    int capacity;
    symbolInfo *slist;
    scopeTable *parentScope;

public:
    int id;
    FILE *fp;
    scopeTable(int cap, scopeTable *parent)
    {
        capacity = cap;
        slist = new symbolInfo[capacity];
        parentScope = parent;
        id = ++scopeCount;
    }

    scopeTable* getParentScope()
    {
        return parentScope;
    }

    long long hashFunc(string const& s)
    {
        const int p = 31;
        const int m = 1e9 + 9;
        long long hash_value = 0;
        long long p_pow = 1;

        int length = s.length();

        for (int i = 0; i < length; i++){
            //if(c>='A' && c<='Z') c = c-'A'+'a';
            //else if(c>='0' && c<='9') c = c-'0'+'a';
            //else c = c-'!'+'a';
            hash_value = (((hash_value + (unsigned long long )s[i]) * p_pow) % m)<<i;
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

        while(temp->next != NULL)
        {
            temp = temp->next;
            //temp->print();
            if(temp->getName() == name)
            {
                if(flag == 0 or flag == 2) cout<<"\n\t"<<name<<" Found in ScopeTable #"<<this->id<<" at position "<<hashValue<<", "<<position<<endl;
                //temp->print();
                return temp;
            }
            position++;
            //cout<<endl;
        }

        if(temp->next == NULL)
        {
            if(flag == 0) cout<<"\n\t"<<name<<" NOT FOUND"<<endl;
            return NULL;
        }

    }

    bool insert(string name,string type,string varType)
    {
        int position = 0;
        symbolInfo *newItem = new symbolInfo();
        symbolInfo *temp ;

        temp = lookUp(name,1);

        if(temp != NULL )
        {
            cout<<"\n\t"<<name<<" already exits in current ScopeTable"<<endl;
            //cout<<"item: ";
            //temp->print();
            //cout<<endl;
            return false;
        }

        int hashValue = getHashValue(name);

        temp = &slist[hashValue];

        //cout<<name<<" "<<type<<endl;
        newItem->setName(name);
        newItem->setType(type);
        newItem->setVariableType(varType);
        //newItem->print();

        while(temp->next != NULL)
        {
            temp = temp->next;
            position++;
        }
        temp->next = newItem;
        cout<<"\n\tInserted ";
        //newItem->print();
        cout<<"\b in ScopeTable #"<<this->id<<" at position "<< hashValue<<", "<<position<<endl;
        return true;
        //slist->next->print();
    }

    bool Delete(string name)
    {
        int hashValue = getHashValue(name);
        int position = 0;

        symbolInfo *temp,*temp2 ;

        temp = &slist[hashValue];

        while(temp->next != NULL)
        {
            if(temp->next->getName() == name)
            {
                temp2 = temp->next;

                temp->next = temp->next->next;

                free(temp2);

                cout<<"\n\t"<<name<<" Found in "<<hashValue<<", "<<position<<" in current ScopeTable"<<endl;


                cout<<"\n\tDeleted entry at "<<hashValue<<", "<<position<<" from current ScopeTable"<<endl;

                return true;
            }
            temp = temp->next;
            position++;
        }

        if(temp->next == NULL)
        {
            cout<<"\n\t"<<name<<" NOT FOUND"<<endl;
            return false;
        }

    }

    void print(FILE *INP)
    {
        symbolInfo * temp;
        fp = INP;

        fprintf(fp,"\nScope Table # %d\n\n",id);
        cout<<"\nScope Table # "<<id<<endl;
        for(int i=0; i<capacity; i++)
        {
            temp = &slist[i];
            fprintf(fp,"\t %d-->  ",i);
            cout<<"\t"<<i<<"-->  ";
            while(temp->next != NULL)
            {
                temp = temp->next;
                temp->print(fp);
            }
            fprintf(fp,"\n");
            cout<<endl;
        }
    }

    ~scopeTable()
    {
        if(slist != NULL){
            free(slist);
        }
    }
};

class SymbolTable
{
    scopeTable *currentScope;
    int capacity;
    FILE *fp;

public:
    SymbolTable(int m,FILE *INP)
    {
        capacity = m;
        currentScope = new scopeTable(capacity,NULL);
        fp = INP; 
    }

    void enterScope()
    {
        scopeTable *cur = currentScope;
        currentScope= new scopeTable(capacity,cur);
        /*scopeCount++;
        currentScope->id = scopeCount;*/
        fprintf(fp,"\n\tNEW SCOPE TABLE WITH ID %d  created\n\n",currentScope->id);
        cout<<"\n\tNEW SCOPE TABLE WITH ID "<<currentScope->id<<" created"<<endl;
    }

    void exitScope()
    {
        scopeTable *cur = currentScope;
        int id = cur->id;
        currentScope = currentScope->getParentScope();
        scopeCount--;
        delete cur;
        
        fprintf(fp,"\n\tScopeTable with id %d  removed\n\n",id);
        cout<<"\n\tScopeTable with id "<<id<<" removed"<<endl;
    }

    bool insert(string name,string type,string varType)
    {
        return currentScope->insert(name,type,varType);
    }

    bool remove(string name)
    {
        return currentScope->Delete(name);
    }

    symbolInfo* lookUp(string name)
    {
        scopeTable *temp;
        temp = currentScope;

        symbolInfo *si;
        while(temp != NULL)
        {
            si = temp->lookUp(name,2);

            if(si != NULL)
            {
                return si;
            }

            temp = temp->getParentScope();
        }

        if(temp == NULL)
        {
            cout<<"\n\t"<<name<<" NOT FOUND"<<endl;
            return NULL;
        }
    }

    symbolInfo* lookUpCur(string name)
    {
        symbolInfo* temp;

        temp = currentScope->lookUp(name);
        if(temp != NULL){
            cout<<"not null";
            return currentScope->lookUp(name);
        }
        else{
            cout<<"NULL";
            return 0;
        }
    }

    void print()
    {
        //currentScope->print();
    }

    void printAll()
    {   
        scopeTable *temp;
        temp = currentScope;
        while(temp != NULL)
        {
            temp->print(fp);
            temp = temp->getParentScope();
            cout<<endl;
        }
    }

};

// int main()
// {
//     freopen("my input.txt","r",stdin);
//     //freopen("myoutput.txt","w",stdout);
//     ios_base::sync_with_stdio(0);
//     int n,m,hashValue;
//     string command;
//     cin>>m;

//     SymbolTable st(m);

//     while(cin>>command)
//     {
//         string name,type;

//         if(command == "I")
//         {
//             cin>>name>>type;
//             //cout<<"\n\tInserting Item...";
//             st.insert(name,type);
//         }

//         else if(command == "L")
//         {
//             cin>>name;
//             //cout<<"\n\tSearching Item...";
//             st.lookUp(name);
//         }

//         else if(command == "D")
//         {
//             cin>>name;
//             //cout<<"\n\tDeleting Item...";
//             st.remove(name);
//         }

//         else if(command == "P")
//         {
//             cin>>name;
//             if(name == "A")
//             {
//                 //cout<<"\nPrinting All Scope Tables...";
//                 st.printAll();
//             }

//             else if(name == "C")
//             {
//                 //cout<<"\nPrinting Current Scope Table...";
//                 st.print();
//             }
//         }

//         else if(command == "S")
//         {
//             //cout<<"\n\tCreating New Scope Table...";
//             st.enterScope();
//         }

//         else if(command == "E")
//         {
//             //cout<<"\n\tExiting Current Scope Table...";
//             st.exitScope();
//         }
//     }

//      return 0;
// }


/*
    st.lookUp("foo");
    st.lookUp("5");
    st.lookUp("alien");

*/

/*
    st.lookUp("foo");
    st.lookUp("5");
    st.lookUp("alien");
    cout<<"deleting foo: ";
    st.remove("foo");
    st.print();
    cout<<endl;
    cout<<"deleting alien: ";
    st.remove("alien");
    st.print();
    cout<<endl;
    */

/*st.print();
cout<<endl;

st.printAll();
cout<<endl;
*/
