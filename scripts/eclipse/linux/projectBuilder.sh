#! /bin/bash

while getopts ":n:c:f:p:i:s:" opt; do
    case $opt in
        n)
            NAME=$OPTARG
        ;;
        c)
            COMMENT=$OPTARG
        ;;
        f)
            FLAGS=$OPTARG
        ;;
        i)
            INCLUDES=$OPTARG
        ;;
        s)
            SYSINCS=$OPTARG
        ;;
        p)
            PROJECTS=$OPTARG
        ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
        ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
        ;;
    esac
done

if [ -z $NAME ]
then
    echo "Name not provided" >&2
    exit 1
fi

PROJECT_DEPS=
PROJECT_DEPS2="<storageModule moduleId=\"org.eclipse.cdt.core.externalSettings\">\n"
PREAMBLE=""
PREAMBLE2="\t\t\t"
for dep in $PROJECTS; do
    DEP_STR="<project>$dep</project>"
    DEP2_STR="\t<externalSettings containerId=\"$dep;\" factoryId=\"org.eclipse.cdt.core.cfg.export.settings.sipplier\"/>\n"
    PROJECT_DEPS="$PROJECT_DEPS$PREAMBLE$DEP_STR"
    PROJECT_DEPS2="$PROJECT_DEPS2$PREAMBLE2$DEP2_STR"
    PREAMBLE="\n\t\t"
done
PROJECT_DEPS2=$PROJECT_DEPS2$PREAMBLE2"</storageModule>"

PROJECT_INCS=
PREAMBLE=""
for inc in $INCLUDES; do
    INC_STR="<listOptionValue builtIn=\"false\" value=\"\&quot;\${workspace_loc:$inc}\&quot;\"/>"
    PROJECT_INCS="$PROJECT_INCS$PREAMBLE$INC_STR"
    PREAMBLE="\n\t\t\t\t\t\t\t\t\t"
done

IFS=;
for inc in $SYSINCS; do
    INC_STR="<listOptionValue builtIn=\"false\" value=\"\&quot;$inc\&quot;\"/>"
    PROJECT_INCS="$PROJECT_INCS$PREAMBLE$INC_STR"
    PREAMBLE="\n\t\t\t\t\t\t\t\t\t"
done

sed -i "s/\$PROJECT_NAME/$NAME/g" .project
sed -i "s/\$PROJECT_COMMENT/$COMMENT/g" .project
sed -i "s#\$PROJECT_REFS#$PROJECT_DEPS#g" .project

sed -i "s/\$CPP_FLAGS/$FLAGS/g" .cproject
sed -i "s#\$PROJECT_INCLUDES#$PROJECT_INCS#g" .cproject
sed -i "s#\$PROJECT_REFS#$PROJECT_DEPS2#g" .cproject

sed -i "s/\$CPP_FLAGS/$FLAGS/g" .settings/language.settings.xml
