#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "parsecmd.h"


/* The maximum size of the circular history queue. */
#define MAXHIST 10


/*
* A struct to keep information one command in the history of
* command executed
*/
struct histlist_t {
   unsigned int cmd_num;
   char cmdline[MAXLINE]; // command line for this process
};


/* Global variables declared here.
* Globals only used to manage history list state.
*/
static struct histlist_t history[MAXHIST];
static int queue_next = 0;  // the next place to insert in the queue
static int queue_size = 0;


void add_queue(char* cmdline);
void print_queue(void);
void sigchild_handler(int signal);


int main(int argc, char **argv) {
   char cmdline[MAXLINE];
   char **args;
   int bg;
   int num_arg;
   int i, pid;
   int ret;
   int z = 0;


     /* register SIGCHLD handler: */
            if ( signal(SIGCHLD, sigchild_handler) == SIG_ERR) {
                printf("ERROR signal failed\n");
                exit(1);
            }


   while (1) {
       // (1) print the shell prompt
       printf("shell> ");
       fflush(stdout);


       // (2) read in the next command entered by the user
       if ((fgets(cmdline, MAXLINE, stdin) == NULL) && ferror(stdin)) {
           perror("fgets error");
       }
       if (feof(stdin)) { /* End of file (ctrl-D) */
           fflush(stdout);
           exit(0);
       }


       
       add_queue(cmdline);


       printf("DEBUG: %s\n", cmdline);


       args = parse_cmd_dynamic(cmdline, &bg);
      
       // count num of args
       i = 0;
       while (args[i] != NULL){
           i++;
       }
       num_arg = i;


       // exit case
       if((strcmp(args[0], "exit") == 0) )
       {
           if(args[1] != NULL)
           {
               printf("Error: extraneous arguments, could not exit\n");
           }
           else{
                z = 0;
                while(args[z] != NULL)
                {
                    free(args[z]);
                    z++;
                }
               free(args);
               exit(1);
           }
       }


       //Case for "cd" with no further args
       else if ((num_arg == 1) && (strcmp(args[0], "cd") == 0)){
           char *path = getenv("HOME");
           if(path != NULL)
           {
               chdir(path);
           }
           else{
               printf("Error: Could not find home directory\n");
           }
          
       }


       // case for cd and another arg
       else if ((num_arg > 1) && (strcmp(args[0], "cd") == 0)){
           ret = chdir(args[1]);
           if(ret == -1)
           {
               printf("Error: could not change directory\n");
           }
       } 


       // history case
       else if((num_arg == 1) && (strcmp(args[0], "history") == 0)){
           print_queue();
       }



        
       // (4) execute non-built in cases
       else{
        if(bg == 0)
        {
            /* create a child process */
            pid = fork();
            if(pid == 0) {
                /* child code...call execvp */
               if(execvp(args[0], args) == -1)
               {
                    printf("%s: Command not found\n", args[0]);
                    z = 0;
                    while(args[z] != NULL)
                    {
                        free(args[z]);
                        z++;
                    }
                    free(args);
                    exit(1);
               }
            }
            else{
                waitpid(pid, NULL, 0);
            }
            /* the parent continues executing concurrently with child */


        }
        else{
            /* create a child process */
            pid = fork();
            if(pid == 0) {
                /* child code...call execvp */
                if(execvp(args[0], args) == -1)
                {
                    printf("%s: Command not found\n", args[0]);
                }
                z = 0;
                while(args[z] != NULL)
                {
                    free(args[z]);
                    z++;
                }
                free(args);
                exit(1);
            }
        }
    }
   }
   z = 0;
   while(args[z] != NULL)
   {
        free(args[z]);
        z++;
   }
   free(args);
   return 0;
}


// Add the val to the circular queue. Update its state
// (the global variables) to reflect that a new value has been added.
void add_queue(char* cmdline) {
    strcpy(history[queue_next].cmdline, cmdline);
    if(queue_next == 0)
    {
        history[queue_next].cmd_num = history[MAXHIST - 1].cmd_num + 1;
    }
    else{
        history[queue_next].cmd_num = history[queue_next-1].cmd_num + 1;
    }
    
   if(queue_next == MAXHIST - 1)
   {
       queue_next = 0;
   }
   else{
       queue_next++;
   }
   if(queue_size < MAXHIST){
    queue_size++;
   }
   
}


// Print out the values in the order that they were added to the
// queue: first to last. For each element, print the bucket in
// the queue array and the value.
void print_queue(void){
    if(queue_size < MAXHIST)
    {
        for(int i=0; i<queue_next; i++)
        {
            printf("%d: %s\n", history[i].cmd_num, history[i].cmdline);
        }
    }
    else{
        for(int i=queue_next; i<MAXHIST; i++)
        {
            printf("%d: %s\n", history[i].cmd_num, history[i].cmdline);
        }
        for(int i=0; i<queue_next; i++)
        {
            printf("%d: %s\n", history[i].cmd_num, history[i].cmdline);
        }
    }
   
   


}


/*
* signal handler for SIGCHLD: reaps zombie children
*  signum: the number of the signal (will be 20 for SIGCHLD)
*/
void sigchild_handler(int signum)
{
   int status;
   pid_t pid;


   /*
    * reap any and all exited child processes
    * (loop because there could be more than one)
    */
   // &status WNOHANG
   while( (pid = waitpid(-1, &status, WNOHANG)) > 0) {
       /* uncomment debug print stmt to see what is being handled
       printf("signal %d me:%d child: %d\n", signum, getpid(), pid);
        */
   }
}
