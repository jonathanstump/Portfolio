#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "parsecmd.h"


int get_num_of_args(const char *cmdline, int len);
char *tokenizer(char *str, int arg);


/*
* This method puts the arguments in the command line into
* their own indexes or tokens that can be accessed individually.
* If the command line ends in an '&' then the arguments should
* be run in the background.
*/
char **parse_cmd_dynamic(const char *cmdline, int *bg){
   int args;
   char **argv;
   int len = strlen(cmdline);
   char *cmdline_copy;
   cmdline_copy = malloc((strlen(cmdline)+1)*sizeof(char));
   cmdline_copy = strcpy( cmdline_copy, cmdline);
   char* amp;
   char* new_line;
   *bg = 0;
  


   amp = strchr(cmdline_copy, '&');
   new_line = strchr(cmdline_copy, '\n');


   if (amp){
       *bg = 1;
       *amp = '\0';
   }


   if(new_line){
       *new_line = '\0';
   }

      
  
   args = get_num_of_args(cmdline_copy, len);
      
  
    // +1 for NULL
   argv = malloc((args+1) * sizeof(char*));


   int x=0;
   while(x<args)
   {
       //i+1 for index staring at zero but first thing
       argv[x] = tokenizer(cmdline_copy, x+1);
       x++;
   }
   argv[args] = NULL;


   free(cmdline_copy);
   return argv;
}


/**
* This method takes in the command line and the length
* of the command line and returns the number of arguments present
*/
int get_num_of_args(const char *cmdline, int len){
   int num_args = 1;
   int i = 0;
   if(isspace(cmdline[0]))
   {
       num_args = 0;
   }
   while(cmdline[i] != '\0')
   {
       if(isspace(cmdline[i]) && (isalnum(cmdline[i+1])))
      {
           num_args++;
      }
      i++;
   }

   return num_args;
}


/**
* This method takes in the potentially modified command line
* and the number that shows which argument needs to be tokenized
* and returns that specific argument as a char pointer.
*/
char *tokenizer(char *str, int arg)
{
   int counter = 1;
   int start_index = 0;
   int end_index = 0;
   int i=0;
   int len = strlen(str);
   char *token;


   // first argument is simpler
   if(arg == 1){

       // finding start index
       for(i=0; i<len; i++)
       {
           if (!isspace(str[i])) {
               start_index = i;
               i = len;
           }
       }


       // finding end index
       for(i=start_index; i<len; i++)
       {
           if (isspace(str[i]) || (str[i] == '\0'))
           {
               end_index = i;
               i = len;
           }
       }


       if(end_index == 0)
       {
           end_index = len;
       }
   }
   else{
       // greater than first arg needs a different way for start
       if(!isspace(str[0]))
       {
           for(i=0; i<len-1; i++)
           {
               if(isspace(str[i]) && !(isspace(str[i+1])))
               {
                   counter++;
                   if(counter == arg){
                       start_index = i+1;
                       i = len;
                   }
               }
           }
       }
       if(isspace(str[0]))
       {
           for(i=0; i<len-1; i++)
           {
               if(isspace(str[i]) && !(isspace(str[i+1])))
               {
                   if(counter == arg){
                       start_index = i+1;
                       i = len;
                   }
                   counter++;
               }
           }
       }
      
       // finding end index
       for(i=start_index; i<len; i++)
       {
           if (isspace(str[i]) || (i == len-1))
           {
               if(i == len-1){
                    if(isspace(str[i]))
                    {
                        end_index = i;
                    }
                    else{
                         end_index = i+1;
                    }
               }
               else{
                   end_index = i;
               }
               i = len;
           }
       }
   }




   /* copying token */
   int length = end_index - start_index +  1;
   token = malloc(length*sizeof(char)); // not length+1 bc end index is one greater
   int z = 0;
   for(i=start_index; i<end_index; i++)
   {
       token[z] = str[i];
       z++;
   }
   token[z] = '\0';
   return token;
}
