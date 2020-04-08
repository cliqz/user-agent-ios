import React, { useCallback } from 'react';
import {
  TouchableWithoutFeedback,
  View,
  Text,
  StyleSheet,
  Button,
  NativeModules,
} from 'react-native';
import NativeDrawable from '../../../components/NativeDrawable';
import { News } from '../hooks/news';

const styles = StyleSheet.create({
  wrapper: {
    width: '100%',
    flexDirection: 'row',
  },
  button: {
    alignItems: 'center',
    flexDirection: 'row',
  },
  buttonText: {
    color: 'white',
    fontSize: 15,
    marginRight: 5,
  },
  buttonIcon: {
    color: '#ffffff',
    height: 20,
    width: 20,
    transform: [{ rotate: '-90deg' }],
  },
  spacer: {
    flex: 1,
  },
  playbackControls: {
    flexDirection: 'row',
  },
});

export default ({
  scrollToNews,
  news,
}: {
  scrollToNews: any;
  news: News[];
}) => {
  const read = useCallback(() => {
    NativeModules.ReadTheNews.read(news);
  }, [news]);
  const next = useCallback(() => {
    NativeModules.ReadTheNews.next();
  }, []);
  const previous = useCallback(() => {
    NativeModules.ReadTheNews.previous();
  }, []);
  return (
    <View style={styles.wrapper}>
      <TouchableWithoutFeedback onPress={scrollToNews}>
        <View style={styles.button}>
          <Text style={styles.buttonText}>News</Text>
          <NativeDrawable
            style={styles.buttonIcon}
            source="nav-back"
            color={styles.buttonIcon.color}
          />
        </View>
      </TouchableWithoutFeedback>
      <View style={styles.spacer} />
      <View style={styles.playbackControls}>
        <Button title="prev" onPress={previous} />
        <Button title="play" onPress={read} />
        <Button title="next" onPress={next} />
      </View>
    </View>
  );
};
