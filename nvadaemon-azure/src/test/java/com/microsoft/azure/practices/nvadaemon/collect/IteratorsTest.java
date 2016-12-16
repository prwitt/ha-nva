package com.microsoft.azure.practices.nvadaemon.collect;

import com.google.common.collect.PeekingIterator;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static org.mockito.Mockito.mock;

public class IteratorsTest {
    @Test
    void test_null_iterator() {
        Assertions.assertThrows(NullPointerException.class,
            () -> Iterators.currentPeekingIterator(null));
    }

    @Test
    void test_iterator_has_next() {
        PeekingIterator<String> peekingIterator = mock(PeekingIterator.class);
        CurrentPeekingIterator<String> currentPeekingIterator =
            Iterators.currentPeekingIterator(peekingIterator);
        Assertions.assertEquals(false, currentPeekingIterator.hasNext());
        Assertions.assertEquals(null, currentPeekingIterator.current());
    }

    @Test
    void test_iterator_current() {
        String one = "one";
        String two = "two";
        String three = "three";
        List<String> strings = Arrays.asList(one, two, three);
        PeekingIterator<String> peekingIterator
            = com.google.common.collect.Iterators.peekingIterator(strings.iterator());
        CurrentPeekingIterator<String> currentPeekingIterator =
            Iterators.currentPeekingIterator(peekingIterator);
        String current = currentPeekingIterator.current();
        Assertions.assertEquals(null, current);
        String next = currentPeekingIterator.next();
        current = currentPeekingIterator.current();
        Assertions.assertEquals(next, current);
    }
}
