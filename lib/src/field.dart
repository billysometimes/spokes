part of spokes;

class Field{

  int maxLength = null;
  bool primaryKey = false;
  bool secondaryKey = false;
  Type fieldType = null;
  var hasManys = null;
  var value = null;

  Field.string({int maxLength:null,bool secondaryKey: false,defaultTo:null}){
    if(maxLength != null){
      this.maxLength = maxLength;
    }
    if(secondaryKey){
      this.secondaryKey = secondaryKey;
    }
    if(defaultTo != null){
      this.value = defaultTo;
    }
    this.fieldType = String;
  }

  Field.date({bool secondaryKey: false,defaultTo:null}){
    if(defaultTo != null){
      this.value = defaultTo;
    }
    if(secondaryKey)
      this.secondaryKey = true;

    this.fieldType = DateTime;
  }

  Field.id(){
    primaryKey = true;
    this.fieldType = String;
  }

  Field.num({var defaultTo: null,bool secondaryKey: false}){
    this.fieldType = num;
    if(defaultTo != null){
      this.value=defaultTo;
    }
    if(secondaryKey)
      this.secondaryKey = true;
  }

  Field.hasMany(var cls){
     this.fieldType = cls;
     this.hasManys = cls;
     this.value = [];
  }

  set(var val){
    this.value = val;

    if(val.runtimeType != fieldType){
      //TODO allow it, but warn the user that they are storing the wrong type
    }
  }

  get(){
    return value;
  }

  operator [](var val){
    set(val);
  }
}