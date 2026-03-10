#!/bin/ksh

#-------------------------------------------------------------------------------
function description
{
  cat <<\EOF
Description:
    Use this to create a basic Maven Java project.

EOF
}
#-------------------------------------------------------------------------------
function usage
{
  cat <<\EOF
Usage:
-h|--help            Show the usage details
-g|--groupId         Set the groupId
-a|--artifactId      Set the artifactId
-p|--projectVersion  Set the projectVersion
-j|--javaVersion     Set the javaVersion

EOF
  exit_flag=true
}
#-------------------------------------------------------------------------------
# Right-pad function name for output
function rpad
{
  typeset -L25 tmpvar=$1
  print "$tmpvar ::"
}
#-------------------------------------------------------------------------------
function print_msg
{
  print -- "$*" 
  [[ -n ${LOGFILE} ]] && print -- "$*" >> ${LOGFILE}
}
#-------------------------------------------------------------------------------
function error_exit
{
  typeset verbose=false
  [[ "$1" = "-v" ]] && shift && verbose=true
  reason="$1"
  print -- "Invalid $reason\n" >&2
  $verbose && usage || exit_flag=true
}
#-------------------------------------------------------------------------------
function check_exit_flag
{
  print $exit_flag
  typeset verbose=false
  [[ "$1" = "-v" ]] && shift && verbose=true
  $exit_flag && { $verbose && usage; exit 1; }
}
#-------------------------------------------------------------------------------
function verify_parameters 
{
  # Check input parameters
  typeset invalid=
  while [[ $# -gt 0 ]] && [[ ."$1" = .-* || ."$1" = .--* ]]; do
    opt="$1"; shift
    case $opt in
    "-h"  |"--help" )  description; usage; check_exit_flag ;;
    "-g"  |"--groupId"  )  groupId="$1"; shift ;;
    "-g="*|"--groupId="*)  groupId="${opt#*=}" ;;
    "-a"  |"--artifactId"  )  artifactId="$1"; shift ;;
    "-a="*|"--artifactId="*)  artifactId="${opt#*=}" ;;
    "-p"  |"--projectVersion"  )  projectVersion="$1"; shift ;;
    "-p="*|"--projectVersion="*)  projectVersion="${opt#*=}" ;;
    "-j"  |"--javaVersion"  )  javaVersion="$1"; shift ;;
    "-j="*|"--javaVersion="*)  javaVersion="${opt#*=}" ;;
    *)  invalid="$invalid $opt" ;;
    esac
  done
  [[ -n $invalid ]] && {
    print >&2 "Invalid option(s): $invalid"; usage; check_exit_flag
  }
  
  ### Ensure all required options are set
  [[ -z ${groupId+x} ]]        && error_exit "- groupId must be set"
  [[ -z ${artifactId+x} ]]     && error_exit "- artifactId must be set"
  [[ -z ${projectVersion+x} ]] && error_exit "- projectVersion must be set"
  [[ -z ${javaVersion+x} ]]    && error_exit "- javaVersion must be set"
  
  check_exit_flag -v
}


#-------------------------------------------------------------------------------
function create_directory_structure
{
	typeset artifactId=$1
	typeset groupId=$2

	print_msg "${acScript} :: Creating the directory structure."
	mkdir -p "./${artifactId}/src/main/java/${groupId/.//}/"
	mkdir -p "./${artifactId}/src/test/java/${groupId/.//}/"
}
#-------------------------------------------------------------------------------
function create_pom_file
{
	typeset groupId=$1
	typeset artifactId=$2
	typeset version=$3
	typeset source=$4
	typeset target=$5

	print_msg "${acScript} :: Creating the pom.xml file."
	cat > ./${artifactId}/pom.xml << EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
		 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
							 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
 
	<groupId>${groupId}</groupId>
	<artifactId>${artifactId}</artifactId>
	<version>${version}</version>
 
	<properties>
		<maven.compiler.source>${source}</maven.compiler.source>
		<maven.compiler.target>${target}</maven.compiler.target>
	</properties>
 
	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>3.8.1</version>
				<configuration>
					<source>${source}</source>
					<target>${target}</target>
				</configuration>
			</plugin>
		</plugins>
	</build>
	
	<dependencies>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<version>4.13</version>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>org.junit.jupiter</groupId>
			<artifactId>junit-jupiter-api</artifactId>
			<version>5.9.0</version>
			<scope>test</scope>
		</dependency>
	</dependencies>

</project>
EOF
}

#===============================================================================
# Main
#===============================================================================
umask 022

typeset THIS_SCRIPT_RELEASE="1.0"
typeset THIS_SCRIPT_DATE="2022-08-08"

typeset -i iError=1
typeset -i iSuccess=0
typeset -i RETCODE
typeset acScript=$(basename $0)
typeset ID=$(id -run)
typeset exit_flag=false

typeset groupId
typeset artifactId
typeset projectVersion
typeset javaVersion

export LOGFILE=$PWD"/"${acScript%%.*}.log.$(date +"%Y%m%d%H%M%S")
# Remove old log files
rm -rf $PWD"/"${acScript%%.*}.log*
touch ${LOGFILE}
chmod 666 ${LOGFILE}
print_msg "Log file is: ${LOGFILE}"

verify_parameters $*

TIMECUR=`date '+%m/%d/%Y %H:%M:%S'`
print_msg "${acScript} :: Release "${THIS_SCRIPT_RELEASE}", Date "${THIS_SCRIPT_DATE}
print_msg "${acScript} $*"
print_msg "${acScript} :: started at "${TIMECUR}
print_msg "${acScript} :: --------------------------------"
typeset SECONDS_BEG=$SECONDS

create_directory_structure $artifactId $groupId
create_pom_file $groupId $artifactId $projectVersion $javaVersion $javaVersion

TIMECUR=`date '+%m/%d/%Y %H:%M:%S'`
print_msg "${acScript} :: --------------------------------"
print_msg "${acScript} :: completed at "${TIMECUR}
typeset SECONDS_END=$SECONDS
print_msg "${acScript} :: total time is $((SECONDS_END-SECONDS_BEG)) second(s)"
print_msg "Log file is: ${LOGFILE}"
