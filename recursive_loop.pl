#!/usr/bin/perl -w
use strict;
use File::Spec;
 
local $\ ="\n";#当前模块的每行输出加入换行符  
 
my %options;
my $tag = "ilk_in.ipf";
my @valid_dir; 
my $dir_list_name = "dir_list.txt";
open f_dir_list, ">".$dir_list_name or die $!;
#目录路径
$options{single_case} = $ARGV[0];
 
  my @cases;
  if (-d $options{single_case}) {#判断目录是否存在
    my @files;
    my $dh;
    push(@files, $options{single_case});
    while (@files) {
      #print "Process: ".$files[0];
      if (-d $files[0]) {#若是目录执行以下操作
        #print "Dir: ",$files[0];
        opendir $dh, $files[0] or die $!;#打开目录句柄,若失败打印错误信息
        @_ = grep { /^[^\.]/ } readdir $dh;#过滤掉以"."和".."的文件,即UNIX下的隐藏文件
        if(grep {$_ eq $tag} @_){
          #print "Have ilk_in.ipf, valid dir\n";
          push(@valid_dir,$files[0]);
          closedir $dh;
          shift @files;
          next; 
        }
        foreach (@_) {
          push(@files, File::Spec->catfile ($files[0], $_));#连接目录名和文件名形成一个完整的文件路径:
        }
        closedir $dh;
      }
      #若是文件直接压入数组@cases中
      elsif ($files[0] =~ /\.t$/) {
        #print "File: ".$files[0];
        push(@cases, $files[0]);
      }
      shift @files;
    }
  }
  else {
    #print "Not Dir";
    @cases = ($options{single_case});
  }
 
print "Valid Dir List is : \n";
print $_ foreach @valid_dir;#打印文件列表
print "\n";
printf f_dir_list $_."\n" foreach @valid_dir;#打印文件列表
close(f_dir_list);
#print "@valid_dir\n";
#foreach $dir_p (@valid_dir) {
#  print "$dir_p\n";
#}