FROM anapsix/alpine-java:8_jdk

LABEL authors="Can Kutlu Kinay <me@ckk.im>, Chris Vincent <seevee@pm.me>"

ENV SDK_VERSION=4333796 \
    TOOLS_VERSION=28.0.1 \
    SDK_CHECKSUM="92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9" \
    ANDROID_HOME="/opt/android-sdk" \
    LD_LIBRARY_PATH="${ANDROID_HOME}/tools/lib64/qt:${ANDROID_HOME}/tools/lib/libQt5:${LD_LIBRARY_PATH}/" \
    GRADLE_VERSION=4.9 \
    GRADLE_HOME="/opt/gradle-${GRADLE_VERSION}"

ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$SDK_VERSION:$GRADLE_HOME/bin

# Add curl
RUN apk add --no-cache curl

# Download Android SDK
RUN curl -SLO "https://dl.google.com/android/repository/sdk-tools-linux-${SDK_VERSION}.zip" && \
    echo "${SDK_CHECKSUM}  sdk-tools-linux-${SDK_VERSION}.zip" | sha256sum -c - && \
    mkdir -p $ANDROID_HOME && \
    unzip "sdk-tools-linux-${SDK_VERSION}.zip" -d "${ANDROID_HOME}" && \
    rm -Rf "sdk-tools-linux-${SDK_VERSION}.zip"

# Accept license agreements
RUN echo y | sdkmanager "platform-tools" "build-tools;${TOOLS_VERSION}" && \
    echo y | sdkmanager "platforms;android-10" "platforms;android-15" "platforms;android-16" "platforms;android-17" "platforms;android-18" "platforms;android-19" && \
    echo y | sdkmanager "platforms;android-20" "platforms;android-21" "platforms;android-22" "platforms;android-23" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" "platforms;android-28" && \
    echo y | sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;instantapps" "extras;google;m2repository" && \
    echo y | sdkmanager "add-ons;addon-google_apis-google-15" "add-ons;addon-google_apis-google-16" "add-ons;addon-google_apis-google-17" "add-ons;addon-google_apis-google-18" "add-ons;addon-google_apis-google-19" "add-ons;addon-google_apis-google-21" "add-ons;addon-google_apis-google-22" "add-ons;addon-google_apis-google-23" "add-ons;addon-google_apis-google-24"

# Here be dragons
RUN mkdir -p $ANDROID_HOME/tools/keymaps \
    && touch $ANDROID_HOME/tools/keymaps/en-us \
    # Licenses taken from https://github.com/mindrunner/docker-android-sdk
    && mkdir -p $ANDROID_HOME/licenses \
    && echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55\n" > $ANDROID_HOME/licenses/android-sdk-license \
    && echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd\n" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Install gradle
RUN curl -SLO "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && mkdir -p "${GRADLE_HOME}" \
    && unzip "gradle-${GRADLE_VERSION}-bin.zip" -d "/opt" \
    && rm -f "gradle-${GRADLE_VERSION}-bin.zip" \
    && apk del curl
